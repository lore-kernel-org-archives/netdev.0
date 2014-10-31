From: Evan Gilman <evan@pagerduty.com>
Subject: Re: Sporadic ESP payload corruption when using IPSec in NAT-T
 Transport Mode
Date: Thu, 30 Oct 2014 17:05:25 -0700
Message-ID: <CALEwOppDfAHV2rghk_nO2Xbjqxd=cbUeW7oWOkAgZtcmjPdHuQ@mail.gmail.com>
References: <CALEwOppxvZ5F1-HeEnEEfe+GXs4=q+Eq+yL6W4xshemW8Wu9Ww@mail.gmail.com>
	<20140630113324.GR32371@secunet.com>
	<20140630132119.GA19500@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140630132119.GA19500@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Indeed, I am using aesni-intel. I have again been bitten by this
problem, but do not have the cycles to pinpoint the kernel version in
which the trouble was introduced. I have done a bit more research, and
have found that hosts running under Xen 4.4.2 are not affected
(regardless of kernel version), while hosts under Xen 4.1.6 and Xen
3.4.3 are affected. The latter is the version we are observing in AWS,
and ami-6d6b6028 (official Ubuntu Trusty image) is affected
out-of-the-box, with the latest kernel available for Trusty (linux
3.13.0). I can also confirm that the corruption ceases to occur after
unloading the aesni-intel kernel module.

I have been using the following test to identify hosts which are
affected, where hostA is known to be unaffected:
-- evan@hostA:~ $ dd if=/dev/zero | nc hostB 8080
2530292+0 records in
2530291+0 records out
1295508992 bytes (1.3 GB) copied, 413.288 s, 3.1 MB/s
^C-- evan@hostA:~ $
...
-- evan@hostB:~ $ nc -l 8080 | xxd -a
0000000: 0000 0000 0000 0000 0000 0000 0000 0000  ................
*
189edea0:0000 1e30 e75c a3ef ab8b 8723 781c a4eb  ...0.\.....#x...
189edeb0:6527 1e30 e75c a3ef ab8b 8723 781c a4eb  e'.0.\.....#x...
189edec0:6527 1e30 e75c a3ef ab8b 8723 781c a4eb  e'.0.\.....#x...
189eded0:6527 1e30 e75c a3ef ab8b 8723 781c a4eb  e'.0.\.....#x...
189edee0:6527 9d05 f655 6228 1366 5365 a932 2841  e'...Ub(.fSe.2(A
189edef0:2663 0000 0000 0000 0000 0000 0000 0000  &c..............
189edf00:0000 0000 0000 0000 0000 0000 0000 0000  ................
*
4927d4e0:5762 b190 5b5d db75 cb39 accd 5b73 982b  Wb..[].u.9..[s.+
4927d4f0:5762 b190 5b5d db75 cb39 accd 5b73 982b  Wb..[].u.9..[s.+
4927d500:5762 b190 5b5d db75 cb39 accd 5b73 982b  Wb..[].u.9..[s.+
4927d510:5762 b190 5b5d db75 cb39 accd 5b73 982b  Wb..[].u.9..[s.+
4927d520:01db 332d cf4b 3804 6f9c a5ad b9c8 0932  ..3-.K8.o......2
4927d530:0000 0000 0000 0000 0000 0000 0000 0000  ................
*
4bb51110:0000 54f8 a1cb 8f0d e916 80a2 0768 3bd3  ..T..........h;.
4bb51120:3794 54f8 a1cb 8f0d e916 80a2 0768 3bd3  7.T..........h;.
4bb51130:3794 54f8 a1cb 8f0d e916 80a2 0768 3bd3  7.T..........h;.
4bb51140:3794 54f8 a1cb 8f0d e916 80a2 0768 3bd3  7.T..........h;.
4bb51150:3794 20a0 1e44 ae70 25b7 7768 7d1d 38b1  7. ..D.p%.wh}.8.
4bb51160:8191 0000 0000 0000 0000 0000 0000 0000  ................
4bb51170:0000 0000 0000 0000 0000 0000 0000 0000  ................
*
4de3d390:0000 0000 0000                           ......
-- evan@hostB:~ $

I hope that this simple test will aide others in reproducing the issue
and/or identifying if they are also affected.

It is possible that the issue has gone unnoticed by many as lots of
applications will gracefully handle the case. We just happened to hit
a bug in our application which failed to check the bound of a
particular value in it's protocol, causing the thread to OOM when it
tried to allocate memory for the bogus value.

Since the corruption can be cured by changing either Xen version or
Linux kernel version, could this be a bug in the interaction between
aesni-intel and Xen itself? If so, it might stand that a fix could be
shipped with a future kernel update, which would be great for people
like us whom cannot control nor convince our providers to upgrade Xen
(i.e. AWS).

I tried to find a reference to the previous report of aesni-intel
causing IPSec corruption under Xen - I'd be interested to read it if
anyone here has it on hand. For now, we are looking to blacklist
aesni-intel as we have no other suitable solution, and when combined
with our other bug, has a detrimental effect on our infrastructure.

On Mon, Jun 30, 2014 at 6:21 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Mon, Jun 30, 2014 at 01:33:24PM +0200, Steffen Klassert wrote:
>> Ccing netdev.
>>
>> On Thu, Jun 26, 2014 at 02:12:30PM -0700, Evan Gilman wrote:
>> >    Hi all
>> >    We have a couple Ubuntu 10.04 hosts with kernel version 3.14.5 which are
>> >    experiencing TCP payload corruption when using IPSec in NAT-T transport
>> >    mode. All are running under Xen at third party providers. When
>> >    communicating with other hosts using IPSec, we see that these corrupt TCP
>> >    PDUs are still being received by the remote listener, even though the TCP
>> >    checksum is invalid.
>> >    All other checksums (IPSec authentication header and IP checksum) are
>> >    good. So, we are thinking that corruption is happening during the ESP
>> >    encapsulation and decapsulation phase (IPSec required for reproduction).
>> >    The corruption occurs sporadically, and we have not found any one
>> >    payload/packet combination that will reliably trigger it, though we can
>> >    typically reproduce it in less than 30 minutes. We can do it very simply
>> >    by reading from /dev/zero with dd and piping through netcat. It occurs
>> >    whenever a 3.14.5 kernel is involved at either end of the conversation. I
>> >    can send captures to those who are interested. Does any of this sound
>> >    familiar?
>>
>> I can't remember anyone reporting such problems, but maybe someone
>> else does.
>
> I have seen one report where a Xen guest experienced IPsec corruption
> when using aesni-intel.  However, in that case the corruption was at
> the authentication level.  Are you using aesni-intel by any chance?
>
> Cheers,
> --
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt



-- 
evan
