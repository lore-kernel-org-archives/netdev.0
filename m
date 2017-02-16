From: lkml@pengaru.com
Subject: Re: [BUG] 4.10-rc8 - ping spinning?
Date: Thu, 16 Feb 2017 04:05:47 -0800
Message-ID: <20170216120547.GK582@shells.gnugeneration.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, soheil@google.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello netdev,

Please see the forwarded message below.  This was sent to linux-kernel but
after digging a little I suspect it's specific to the network stack.

Perusing the net/ changes between 4.9 and 4.10-rc8 this sounded awful related
to what I'm observing:

commit 83a1a1a70e87f676fbb6086b26b6ac7f7fdd107d
Author: Soheil Hassas Yeganeh <soheil@google.com>
Date:   Wed Nov 30 14:01:08 2016 -0500

    sock: reset sk_err for ICMP packets read from error queue
    
    Only when ICMP packets are enqueued onto the error queue,
    sk_err is also set. Before f5f99309fa74 (sock: do not set sk_err
    in sock_dequeue_err_skb), a subsequent error queue read
    would set sk_err to the next error on the queue, or 0 if empty.
    As no error types other than ICMP set this field, sk_err should
    not be modified upon dequeuing them.
    
    Only for ICMP errors, reset the (racy) sk_err. Some applications,
    like traceroute, rely on it and go into a futile busy POLLERR
    loop otherwise.
    
    In principle, sk_err has to be set while an ICMP error is queued.
    Testing is_icmp_err_skb(skb_next) approximates this without
    requiring a full queue walk. Applications that receive both ICMP
    and other errors cannot rely on this legacy behavior, as other
    errors do not set sk_err in the first place.
    
    Fixes: f5f99309fa74 (sock: do not set sk_err in sock_dequeue_err_skb)
    Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
    Signed-off-by: Willem de Bruijn <willemb@google.com>
    Acked-by: Eric Dumazet <edumazet@google.com>
    Acked-by: Maciej Żenczykowski <maze@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Cheers,
Vito Caputo


----- Forwarded message from lkml@pengaru.com -----

Date: Thu, 16 Feb 2017 03:17:49 -0800
From: lkml@pengaru.com
To: linux-kernel@vger.kernel.org
Subject: Re: [BUG] 4.10-rc8 - ping spinning?
User-Agent: Mutt/1.5.23 (2014-03-12)

On Thu, Feb 16, 2017 at 03:03:03AM -0800, lkml@pengaru.com wrote:
> Hello list,
> 
> Some rtl8192cu bugs of old got me in the habit of running ping in a shelved     (i.e. forgotten) xterm, a harmless practice which seemed to prevent the         rtl8192cu device from dying.
> 
> This evening the system started getting very slow and to my surprise I found
> this in `top`:
>  5115 swivel    30  10   14772   1928   1756 R  90.9  0.0   1351:41 ping
>  9005 swivel    30  10   14772   1892   1724 R  90.9  0.0   1354:26 ping
> 
> This is a dual core machine (X61s, core2duo 1.8Ghz), those processes are
> burning all the free CPU in the system context.  They're identical commands,
> just plain `ping domain.com`, to the same host.  It appears I accidentally
> (fortuitously?) had two running, which made this event more interesting.
> 
> I can assert that these did not begin spinning simultaneously - as you can see
> by the cumulative time in `top` there's a small delta.  I also use a window
> manager with builtin continuous process monitoring, and when I noticed this was
> happening I was able to see that one of the processes had only recently begun
> spinning, the other was spinning long enough to have its start fall off the
> chart (at least ~17 minutes ago).
> 
> This hasn't occurred before AFAIK, but I haven't spent much time in 4.10 yet.
> I'm pretty confident this didn't happen in 4.9 which I ran for quite a while.
> 
> `strace` of one of the aforementioned processes:
> 
> 1487241315.073568 poll([{fd=3, events=POLLIN|POLLERR}], 1, 927) = 1 ([{fd=3, revents=POLLERR}]) <0.000022>
> 1487241315.073665 recvmsg(3, 0x7ffc8e05e260, MSG_DONTWAIT) = -1 EAGAIN (Resource temporarily unavailable) <0.000020>
> 1487241315.073747 gettimeofday({1487241315, 73774}, NULL) = 0 <0.000021>
> 1487241315.073829 poll([{fd=3, events=POLLIN|POLLERR}], 1, 927) = 1 ([{fd=3, revents=POLLERR}]) <0.000025>
> 1487241315.073927 recvmsg(3, 0x7ffc8e05e260, MSG_DONTWAIT) = -1 EAGAIN (Resource temporarily unavailable) <0.000020>
> 1487241315.074024 gettimeofday({1487241315, 74050}, NULL) = 0 <0.000256>
> 1487241315.074352 poll([{fd=3, events=POLLIN|POLLERR}], 1, 927) = 1 ([{fd=3, revents=POLLERR}]) <0.000026>
> 1487241315.076241 recvmsg(3, 0x7ffc8e05e260, MSG_DONTWAIT) = -1 EAGAIN (Resource temporarily unavailable) <0.000022>
> 1487241315.076337 gettimeofday({1487241315, 76366}, NULL) = 0 <0.000020>
> 1487241315.076422 poll([{fd=3, events=POLLIN|POLLERR}], 1, 924) = 1 ([{fd=3, revents=POLLERR}]) <0.000025>
> 1487241315.076523 recvmsg(3, 0x7ffc8e05e260, MSG_DONTWAIT) = -1 EAGAIN (Resource temporarily unavailable) <0.000025>
> 1487241315.079770 gettimeofday({1487241315, 79799}, NULL) = 0 <0.000019>
> 1487241315.079855 poll([{fd=3, events=POLLIN|POLLERR}], 1, 921) = 1 ([{fd=3, revents=POLLERR}]) <0.000024>
> 1487241315.079956 recvmsg(3, 0x7ffc8e05e260, MSG_DONTWAIT) = -1 EAGAIN (Resource temporarily unavailable) <0.000021>
> 1487241315.080057 gettimeofday({1487241315, 80084}, NULL) = 0 <0.000020>
> 1487241315.080140 poll([{fd=3, events=POLLIN|POLLERR}], 1, 921) = 1 ([{fd=3, revents=POLLERR}]) <0.000024>
> 1487241315.080238 recvmsg(3, 0x7ffc8e05e260, MSG_DONTWAIT) = -1 EAGAIN (Resource temporarily unavailable) <0.000021>
> 1487241315.080322 gettimeofday({1487241315, 80350}, NULL) = 0 <0.000020>
> 1487241315.080406 poll([{fd=3, events=POLLIN|POLLERR}], 1, 920) = 1 ([{fd=3, revents=POLLERR}]) <0.000023>
> 1487241315.080502 recvmsg(3, 0x7ffc8e05e260, MSG_DONTWAIT) = -1 EAGAIN (Resource temporarily unavailable) <0.000019>
> 1487241315.080583 gettimeofday({1487241315, 80610}, NULL) = 0 <0.000018>
> 1487241315.080663 poll([{fd=3, events=POLLIN|POLLERR}], 1, 920) = 1 ([{fd=3, revents=POLLERR}]) <0.000024>
> 1487241315.080761 recvmsg(3, 0x7ffc8e05e260, MSG_DONTWAIT) = -1 EAGAIN (Resource temporarily unavailable) <0.000020>
> 1487241315.080843 gettimeofday({1487241315, 80870}, NULL) = 0 <0.000020>
> 1487241315.080925 poll([{fd=3, events=POLLIN|POLLERR}], 1, 920) = 1 ([{fd=3, revents=POLLERR}]) <0.000037>
> 1487241315.081037 recvmsg(3, 0x7ffc8e05e260, MSG_DONTWAIT) = -1 EAGAIN (Resource temporarily unavailable) <0.000020>
> 1487241315.081119 gettimeofday({1487241315, 81147}, NULL) = 0 <0.000020>
> 

It's worth noting that ping is still otherwise functioning correctly, despite
the POLLERR:

1487242826.169502 sendmsg(3, {msg_name(16)={sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("xx.xxx.xxx.xxx")}, msg_iov(1)=[{"\10\0\245G\23\373\243uJ\206\245X\0\0\0\0\352\225\2\0\0\0\0\0\20\21\22\23\24\25\26\27"..., 64}], msg_controllen=0, msg_flags=0}, MSG_CONFIRM) = 64 <0.000133>
1487242826.169757 recvmsg(3, {msg_name(16)={sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("66.240.222.126")}, msg_iov(1)=[{"E \0T\345\364\0\0002\1w\23B\360\336~\n\0\0\23\0\0\255G\23\373\243uJ\206\245X"..., 192}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_SOCKET, cmsg_type=0x1d /* SCM_??? */, ...}, msg_flags=0}, 0) = 84 <0.028825>
1487242826.198697 write(1, "64 bytes from xxxxxxx.com (xx.xx"..., 79) = 79 <0.000639>
1487242826.199405 gettimeofday({1487242826, 199430}, NULL) = 0 <0.000023>
1487242826.199486 poll([{fd=3, events=POLLIN|POLLERR}], 1, 970) = 1 ([{fd=3, revents=POLLERR}]) <0.000026>
1487242826.199578 recvmsg(3, 0x7ffc8e05e260, MSG_DONTWAIT) = -1 EAGAIN (Resource temporarily unavailable) <0.000024>

Surprisingly ping doesn't seem to be reacting to the POLLERR though it
requested it.  Maybe this is just a ping bug?  Though I haven't seen this
before rc8.

Regards,
Vito Caputo

----- End forwarded message -----
