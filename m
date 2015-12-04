From: Stefan Priebe <s.priebe@profihost.ag>
Subject: Re: Asterisk deadlocks since Kernel 4.1
Date: Fri, 4 Dec 2015 19:26:12 +0100
Message-ID: <5661DAC4.8040909@profihost.ag>
References: <564B3D35.50004@profihost.ag>
 <alpine.DEB.2.11.1511171936030.3761@nanos> <564B7F9D.5060701@profihost.ag>
 <alpine.DEB.2.11.1511172041480.3761@nanos> <564CDE2F.8000201@profihost.ag>
 <564CEB0C.40006@redhat.com> <564CEF5D.3080005@profihost.ag>
 <564D9A17.6080305@redhat.com> <564D9B21.302@profihost.ag>
 <564D9CE6.2090104@profihost.ag>
 <1447933294.1974772.444210441.67F1AC5E@webmail.messagingengine.com>
 <564DB5F5.9060208@profihost.ag>
 <1447936902.1986892.444251921.3928A049@webmail.messagingengine.com>
 <564DC4A5.70104@profihost.ag> <564DCC4C.1090009@redhat.com>
 <564E2852.8000200@profihost.ag> <56530A42.6030609@profihost.ag>
 <1448283451.4019628.447573353.3659E447@webmail.messagingengine.com>
 <565EBDC1.1090808@profihost.ag> <8737vlt6xb.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Weimer <fweimer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8737vlt6xb.fsf@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I got it fixed / at least not live / deadlocking by doing applying the 
following patch - which is the diff of the commits below on top of 4.1.13.

patch:
http://pastebin.com/raw.php?i=hiuq4bsW

all commits / changes in reverse order:

* 0ceb380 - (6 weeks ago) netlink: fix locking around 
NETLINK_LIST_MEMBERSHIPS - David Herrmann (HEAD)
* c3f272b - (7 weeks ago) netlink: Trim skb to alloc size to avoid 
MSG_TRUNC - Arad, Ronen
* 9f87e0c - (2 months ago) netlink: Replace rhash_portid with bound - 
Herbert Xu
* 35e9890 - (3 months ago) netlink: Fix autobind race condition that 
leads to zero port ID - Herbert Xu
* f1d1215 - (3 months ago) netlink, mmap: transform mmap skb into full 
skb on taps - Daniel Borkmann
* faad871 - (3 months ago) netlink, mmap: fix edge-case leakages in nf 
queue zero-copy - Daniel Borkmann
* fb18c94 - (3 months ago) netlink, mmap: don't walk rx ring on poll if 
receive queue non-empty - Daniel Borkmann
* da13789 - (3 months ago) netlink: rx mmap: fix POLLIN condition - 
Ken-ichirou MATSUZAWA
* 808071f - (3 months ago) netlink: mmap: fix lookup frame position - 
Ken-ichirou MATSUZAWA
* 589bfd5 - (3 months ago) netlink: add NETLINK_CAP_ACK socket option - 
Christophe Ricard
* d23c4eb - (4 months ago) netlink: mmap: fix tx type check - 
Ken-ichirou MATSUZAWA
* 5dcc50a - (4 months ago) netlink: make sure -EBUSY won't escape from 
netlink_insert - Daniel Borkmann
* ada2b3e - (5 months ago) netlink: don't hold mutex in rcu callback 
when releasing mmapd ring - Florian Westphal
* e0f54a3 - (5 months ago) netlink: Delete an unnecessary check before 
the function call "module_put" - Markus Elfring
* 0a5bdaf - (6 months ago) netlink: add API to retrieve all group 
memberships - David Herrmann
* 30c6472 - (7 months ago) netlink: Use random autobind rover - Herbert Xu
* 021a670 - (7 months ago) netlink: Create kernel netlink sockets in the 
proper network namespace - Eric W. Biederman
* e1b01b4 - (7 months ago) net: Pass kern from net_proto_family.create 
to sk_alloc - Eric W. Biederman
* dd4b3c9 - (7 months ago) netlink: rename private flags and states - 
Nicolas Dichtel
* 0356126 - (2 days ago) Revert "netlink: don't hold mutex in rcu 
callback when releasing mmapd ring" - Stefan Priebe
* 231d0da - (2 days ago) Revert "netlink: make sure -EBUSY won't escape 
from netlink_insert" - Stefan Priebe
* e0f56af1 - (2 days ago) Revert "netlink, mmap: transform mmap skb into 
full skb on taps" - Stefan Priebe
* 23a0326 - (2 days ago) Revert "netlink: Fix autobind race condition 
that leads to zero port ID" - Stefan Priebe
* 97f4677 - (2 days ago) Revert "netlink: Replace rhash_portid with 
bound" - Stefan Priebe
* 40c851fe - (2 days ago) Revert "netlink: Trim skb to alloc size to 
avoid MSG_TRUNC" - Stefan Priebe
* 1f2ce4a - (4 weeks ago) Linux 4.1.13 - Greg Kroah-Hartman (v4.1.13, 
origin/linux-4.1.y)

So the netlink code is in line with 4.3.

Stefan

Am 02.12.2015 um 12:40 schrieb Hannes Frederic Sowa:
> Hello Stefan,
>
> Stefan Priebe - Profihost AG <s.priebe@profihost.ag> writes:
>
>
>> here are the results.
>>
>> It works with 4.1.
>> It works with 4.2.
>> It does not work with 4.1.13.
>>
>> git bisect tells me it stopped working after those two commits were applied:
>>
>> commit d48623677191e0f035d7afd344f92cf880b01f8e
>> Author: Herbert Xu <herbert@gondor.apana.org.au>
>> Date:   Tue Sep 22 11:38:56 2015 +0800
>>
>>      netlink: Replace rhash_portid with bound
>>
>> commit 4e27762417669cb459971635be550eb7b5598286
>> Author: Herbert Xu <herbert@gondor.apana.org.au>
>> Date:   Fri Sep 18 19:16:50 2015 +0800
>>
>>      netlink: Fix autobind race condition that leads to zero port ID
>
> Cool, thanks a lot. Does this patch make a difference?
>
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 59651af..278e94c 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -1137,7 +1137,7 @@ static int netlink_insert(struct sock *sk, u32 portid)
>
>   	/* We need to ensure that the socket is hashed and visible. */
>   	smp_wmb();
> -	nlk_sk(sk)->bound = portid;
> +	nlk_sk(sk)->bound = true;
>
>   err:
>   	release_sock(sk);
>
