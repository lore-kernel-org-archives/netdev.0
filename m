From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [BUG] 4.10-rc8 - ping spinning?
Date: Thu, 16 Feb 2017 10:52:19 -0500
Message-ID: <CACSApvYbP9peXPm2L4EFJokdXbGV7bTLgZNOEKEiHjLWcOOZHA@mail.gmail.com>
References: <20170216120547.GK582@shells.gnugeneration.com> <CACSApvYq-7HGAO+UTsoCu6JVt_E4mdXKgpUbRD0YDP_M02ZdkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: lkml@pengaru.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACSApvYq-7HGAO+UTsoCu6JVt_E4mdXKgpUbRD0YDP_M02ZdkQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 16, 2017 at 10:50 AM, Soheil Hassas Yeganeh
<soheil@google.com> wrote:
> Thank you Vito for the report.
>
> The patch you cited actually resolves a similar backward compatibility
> problem for traceroute.
>
> I suspect the problem here is that there's a local error queued on the
> error queue after an ICMP message. ping apparently expect the
> sk->sk_err to be set for the local errors as well, and hence the
> error. Ideally, ping should read the error queue if there an EPOLLERR,
> because local errors never sk->sk_err on their own. That is, if we
> have

[oops] That is, if we have only one local error on the error queue, we
cannot rely on having an error on recvmsg (i.e., sk->sk_err being set)
even in 4.9.

Thanks,
Soheil

> But as a workaround, would you mind trying the following patch to see
> if it resolves the issue reported?
>
> From: Soheil Hassas Yeganeh <soheil@google.com>
> Date: Thu, 16 Feb 2017 10:48:24 -0500
> ---
>  net/core/skbuff.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 734c71468b01..2b774b564024 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3717,7 +3717,8 @@ EXPORT_SYMBOL(sock_queue_err_skb);
>  static bool is_icmp_err_skb(const struct sk_buff *skb)
>  {
>   return skb && (SKB_EXT_ERR(skb)->ee.ee_origin =3D=3D SO_EE_ORIGIN_ICMP =
||
> -       SKB_EXT_ERR(skb)->ee.ee_origin =3D=3D SO_EE_ORIGIN_ICMP6);
> +       SKB_EXT_ERR(skb)->ee.ee_origin =3D=3D SO_EE_ORIGIN_ICMP6 ||
> +       SKB_EXT_ERR(skb)->ee.ee_origin =3D=3D SO_EE_ORIGIN_LOCAL);
>  }
>
>  struct sk_buff *sock_dequeue_err_skb(struct sock *sk)
> --
>
> Thanks!
> Soheil
>
> On Thu, Feb 16, 2017 at 7:05 AM,  <lkml@pengaru.com> wrote:
>> Hello netdev,
>>
>> Please see the forwarded message below.  This was sent to linux-kernel b=
ut
>> after digging a little I suspect it's specific to the network stack.
>>
>> Perusing the net/ changes between 4.9 and 4.10-rc8 this sounded awful re=
lated
>> to what I'm observing:
>>
>> commit 83a1a1a70e87f676fbb6086b26b6ac7f7fdd107d
>> Author: Soheil Hassas Yeganeh <soheil@google.com>
>> Date:   Wed Nov 30 14:01:08 2016 -0500
>>
>>     sock: reset sk_err for ICMP packets read from error queue
>>
>>     Only when ICMP packets are enqueued onto the error queue,
>>     sk_err is also set. Before f5f99309fa74 (sock: do not set sk_err
>>     in sock_dequeue_err_skb), a subsequent error queue read
>>     would set sk_err to the next error on the queue, or 0 if empty.
>>     As no error types other than ICMP set this field, sk_err should
>>     not be modified upon dequeuing them.
>>
>>     Only for ICMP errors, reset the (racy) sk_err. Some applications,
>>     like traceroute, rely on it and go into a futile busy POLLERR
>>     loop otherwise.
>>
>>     In principle, sk_err has to be set while an ICMP error is queued.
>>     Testing is_icmp_err_skb(skb_next) approximates this without
>>     requiring a full queue walk. Applications that receive both ICMP
>>     and other errors cannot rely on this legacy behavior, as other
>>     errors do not set sk_err in the first place.
>>
>>     Fixes: f5f99309fa74 (sock: do not set sk_err in sock_dequeue_err_skb=
)
>>     Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
>>     Signed-off-by: Willem de Bruijn <willemb@google.com>
>>     Acked-by: Eric Dumazet <edumazet@google.com>
>>     Acked-by: Maciej =C5=BBenczykowski <maze@google.com>
>>     Signed-off-by: David S. Miller <davem@davemloft.net>
>>
>> Cheers,
>> Vito Caputo
>>
>>
>> ----- Forwarded message from lkml@pengaru.com -----
>>
>> Date: Thu, 16 Feb 2017 03:17:49 -0800
>> From: lkml@pengaru.com
>> To: linux-kernel@vger.kernel.org
>> Subject: Re: [BUG] 4.10-rc8 - ping spinning?
>> User-Agent: Mutt/1.5.23 (2014-03-12)
>>
>> On Thu, Feb 16, 2017 at 03:03:03AM -0800, lkml@pengaru.com wrote:
>>> Hello list,
>>>
>>> Some rtl8192cu bugs of old got me in the habit of running ping in a she=
lved     (i.e. forgotten) xterm, a harmless practice which seemed to preven=
t the         rtl8192cu device from dying.
>>>
>>> This evening the system started getting very slow and to my surprise I =
found
>>> this in `top`:
>>>  5115 swivel    30  10   14772   1928   1756 R  90.9  0.0   1351:41 pin=
g
>>>  9005 swivel    30  10   14772   1892   1724 R  90.9  0.0   1354:26 pin=
g
>>>
>>> This is a dual core machine (X61s, core2duo 1.8Ghz), those processes ar=
e
>>> burning all the free CPU in the system context.  They're identical comm=
ands,
>>> just plain `ping domain.com`, to the same host.  It appears I accidenta=
lly
>>> (fortuitously?) had two running, which made this event more interesting=
.
>>>
>>> I can assert that these did not begin spinning simultaneously - as you =
can see
>>> by the cumulative time in `top` there's a small delta.  I also use a wi=
ndow
>>> manager with builtin continuous process monitoring, and when I noticed =
this was
>>> happening I was able to see that one of the processes had only recently=
 begun
>>> spinning, the other was spinning long enough to have its start fall off=
 the
>>> chart (at least ~17 minutes ago).
>>>
>>> This hasn't occurred before AFAIK, but I haven't spent much time in 4.1=
0 yet.
>>> I'm pretty confident this didn't happen in 4.9 which I ran for quite a =
while.
>>>
>>> `strace` of one of the aforementioned processes:
>>>
>>> 1487241315.073568 poll([{fd=3D3, events=3DPOLLIN|POLLERR}], 1, 927) =3D=
 1 ([{fd=3D3, revents=3DPOLLERR}]) <0.000022>
>>> 1487241315.073665 recvmsg(3, 0x7ffc8e05e260, MSG_DONTWAIT) =3D -1 EAGAI=
N (Resource temporarily unavailable) <0.000020>
>>> 1487241315.073747 gettimeofday({1487241315, 73774}, NULL) =3D 0 <0.0000=
21>
>>> 1487241315.073829 poll([{fd=3D3, events=3DPOLLIN|POLLERR}], 1, 927) =3D=
 1 ([{fd=3D3, revents=3DPOLLERR}]) <0.000025>
>>> 1487241315.073927 recvmsg(3, 0x7ffc8e05e260, MSG_DONTWAIT) =3D -1 EAGAI=
N (Resource temporarily unavailable) <0.000020>
>>> 1487241315.074024 gettimeofday({1487241315, 74050}, NULL) =3D 0 <0.0002=
56>
>>> 1487241315.074352 poll([{fd=3D3, events=3DPOLLIN|POLLERR}], 1, 927) =3D=
 1 ([{fd=3D3, revents=3DPOLLERR}]) <0.000026>
>>> 1487241315.076241 recvmsg(3, 0x7ffc8e05e260, MSG_DONTWAIT) =3D -1 EAGAI=
N (Resource temporarily unavailable) <0.000022>
>>> 1487241315.076337 gettimeofday({1487241315, 76366}, NULL) =3D 0 <0.0000=
20>
>>> 1487241315.076422 poll([{fd=3D3, events=3DPOLLIN|POLLERR}], 1, 924) =3D=
 1 ([{fd=3D3, revents=3DPOLLERR}]) <0.000025>
>>> 1487241315.076523 recvmsg(3, 0x7ffc8e05e260, MSG_DONTWAIT) =3D -1 EAGAI=
N (Resource temporarily unavailable) <0.000025>
>>> 1487241315.079770 gettimeofday({1487241315, 79799}, NULL) =3D 0 <0.0000=
19>
>>> 1487241315.079855 poll([{fd=3D3, events=3DPOLLIN|POLLERR}], 1, 921) =3D=
 1 ([{fd=3D3, revents=3DPOLLERR}]) <0.000024>
>>> 1487241315.079956 recvmsg(3, 0x7ffc8e05e260, MSG_DONTWAIT) =3D -1 EAGAI=
N (Resource temporarily unavailable) <0.000021>
>>> 1487241315.080057 gettimeofday({1487241315, 80084}, NULL) =3D 0 <0.0000=
20>
>>> 1487241315.080140 poll([{fd=3D3, events=3DPOLLIN|POLLERR}], 1, 921) =3D=
 1 ([{fd=3D3, revents=3DPOLLERR}]) <0.000024>
>>> 1487241315.080238 recvmsg(3, 0x7ffc8e05e260, MSG_DONTWAIT) =3D -1 EAGAI=
N (Resource temporarily unavailable) <0.000021>
>>> 1487241315.080322 gettimeofday({1487241315, 80350}, NULL) =3D 0 <0.0000=
20>
>>> 1487241315.080406 poll([{fd=3D3, events=3DPOLLIN|POLLERR}], 1, 920) =3D=
 1 ([{fd=3D3, revents=3DPOLLERR}]) <0.000023>
>>> 1487241315.080502 recvmsg(3, 0x7ffc8e05e260, MSG_DONTWAIT) =3D -1 EAGAI=
N (Resource temporarily unavailable) <0.000019>
>>> 1487241315.080583 gettimeofday({1487241315, 80610}, NULL) =3D 0 <0.0000=
18>
>>> 1487241315.080663 poll([{fd=3D3, events=3DPOLLIN|POLLERR}], 1, 920) =3D=
 1 ([{fd=3D3, revents=3DPOLLERR}]) <0.000024>
>>> 1487241315.080761 recvmsg(3, 0x7ffc8e05e260, MSG_DONTWAIT) =3D -1 EAGAI=
N (Resource temporarily unavailable) <0.000020>
>>> 1487241315.080843 gettimeofday({1487241315, 80870}, NULL) =3D 0 <0.0000=
20>
>>> 1487241315.080925 poll([{fd=3D3, events=3DPOLLIN|POLLERR}], 1, 920) =3D=
 1 ([{fd=3D3, revents=3DPOLLERR}]) <0.000037>
>>> 1487241315.081037 recvmsg(3, 0x7ffc8e05e260, MSG_DONTWAIT) =3D -1 EAGAI=
N (Resource temporarily unavailable) <0.000020>
>>> 1487241315.081119 gettimeofday({1487241315, 81147}, NULL) =3D 0 <0.0000=
20>
>>>
>>
>> It's worth noting that ping is still otherwise functioning correctly, de=
spite
>> the POLLERR:
>>
>> 1487242826.169502 sendmsg(3, {msg_name(16)=3D{sa_family=3DAF_INET, sin_p=
ort=3Dhtons(0), sin_addr=3Dinet_addr("xx.xxx.xxx.xxx")}, msg_iov(1)=3D[{"\1=
0\0\245G\23\373\243uJ\206\245X\0\0\0\0\352\225\2\0\0\0\0\0\20\21\22\23\24\2=
5\26\27"..., 64}], msg_controllen=3D0, msg_flags=3D0}, MSG_CONFIRM) =3D 64 =
<0.000133>
>> 1487242826.169757 recvmsg(3, {msg_name(16)=3D{sa_family=3DAF_INET, sin_p=
ort=3Dhtons(0), sin_addr=3Dinet_addr("66.240.222.126")}, msg_iov(1)=3D[{"E =
\0T\345\364\0\0002\1w\23B\360\336~\n\0\0\23\0\0\255G\23\373\243uJ\206\245X"=
..., 192}], msg_controllen=3D32, {cmsg_len=3D32, cmsg_level=3DSOL_SOCKET, c=
msg_type=3D0x1d /* SCM_??? */, ...}, msg_flags=3D0}, 0) =3D 84 <0.028825>
>> 1487242826.198697 write(1, "64 bytes from xxxxxxx.com (xx.xx"..., 79) =
=3D 79 <0.000639>
>> 1487242826.199405 gettimeofday({1487242826, 199430}, NULL) =3D 0 <0.0000=
23>
>> 1487242826.199486 poll([{fd=3D3, events=3DPOLLIN|POLLERR}], 1, 970) =3D =
1 ([{fd=3D3, revents=3DPOLLERR}]) <0.000026>
>> 1487242826.199578 recvmsg(3, 0x7ffc8e05e260, MSG_DONTWAIT) =3D -1 EAGAIN=
 (Resource temporarily unavailable) <0.000024>
>>
>> Surprisingly ping doesn't seem to be reacting to the POLLERR though it
>> requested it.  Maybe this is just a ping bug?  Though I haven't seen thi=
s
>> before rc8.
>>
>> Regards,
>> Vito Caputo
>>
>> ----- End forwarded message -----
