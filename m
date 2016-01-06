From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [REGRESSION] tcp/ipv4: kernel panic because of (possible)
 division by zero
Date: Wed, 6 Jan 2016 10:43:45 -0800
Message-ID: <CAK6E8=chikkT02ygDHzHN9xP7q7kzWUqHEVgj7g0oW_RUPcuoA@mail.gmail.com>
References: <26396443.iDTTxgChSj@spock> <CAK6E8=d1FquYTtMXi6v+koruRhA2MUe693-DX5jbU8urRatUoQ@mail.gmail.com>
 <DDC4BD3D-A5F5-4EBF-8461-7C63ABC9F852@natalenko.name> <CAK6E8=dSRmf35AaC6mOcRaGSxn81CE76WiOfNx6jb5X8uhDGqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>
To: Oleksandr Natalenko <oleksandr@natalenko.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK6E8=dSRmf35AaC6mOcRaGSxn81CE76WiOfNx6jb5X8uhDGqw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 6, 2016 at 10:19 AM, Yuchung Cheng <ycheng@google.com> wrot=
e:
> On Wed, Jan 6, 2016 at 8:50 AM, Oleksandr Natalenko
> <oleksandr@natalenko.name> wrote:
>>
>> Unfortunately, the patch didn't help -- I've got the same stacktrace=
 with slightly different offset (+3) within the function.
>>
>> Now trying to get full stacktrace via netconsole. Need more time.
>>
>> Meanwhile, any other ideas on what went wrong?
>
> That's odd b/c the patch already checks and avoids div0. Can post me
> the stacktrace and kernel warnings if any ...
>
> One possibility is that tcp_cwnd_reduction() may set a cwnd of 0,
> which then gets used to start another recovery phase. This may or may
> not be the culprit of this div0 issue because I wasn't able to
> reproduce exactly your issue on our servers. But I will post the fix
> today and CC you.
Could you turn off ecn (sysctl net.ipv4.tcp_ecn=3D0) to see if this sti=
ll happen?

>
>>
>>
>> On December 22, 2015 4:10:32 AM EET, Yuchung Cheng <ycheng@google.co=
m> wrote:
>> >On Mon, Dec 21, 2015 at 12:25 PM, Oleksandr Natalenko
>> ><oleksandr@natalenko.name> wrote:
>> >> Commit 3759824da87b30ce7a35b4873b62b0ba38905ef5 (tcp: PRR uses CR=
B
>> >mode by
>> >> default and SS mode conditionally) introduced changes to
>> >net/ipv4/tcp_input.c
>> >> tcp_cwnd_reduction() that, possibly, cause division by zero, and
>> >therefore,
>> >> kernel panic in interrupt handler [1].
>> >>
>> >> Reverting 3759824da87b30ce7a35b4873b62b0ba38905ef5 seems to fix t=
he
>> >issue.
>> >>
>> >> I'm able to reproduce the issue on 4.3.0=E2=80=934.3.3 once per s=
everal day
>> >> (occasionally).
>> >>
>> >> What could be done to help in debugging this issue?
>> >Do you have ECN enabled (i.e. sysctl net.ipv4.tcp_ecn > 0)?
>> >
>> >If so I suspect an ACK carrying ECE during CA_Loss causes entering =
CWR
>> >state w/o calling tcp_init_cwnd_reduct() to set tp->prior_cwnd. Can
>> >you try this debug / quick-fix patch and send me the error message =
if
>> >any?
>> >
>> >
>> >>
>> >> Regards,
>> >>   Oleksandr.
>> >>
>> >> [1] http://i.piccy.info/
>> >>
>> >i9/6f5cb187c4ff282d189f78c63f95af43/1450729403/283985/951663/panic.=
jpg
>>
>> --
>> Sent from my Android device with K-9 Mail. Please excuse my brevity.
