From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH RFC v2 00/12] socket sendmsg MSG_ZEROCOPY
Date: Fri, 24 Feb 2017 19:25:31 -0500
Message-ID: <CAF=yD-JtbsK5s1Y9Ze79aXLuOT5s-3=ZsVB3kdDbuqyZX3HYSg@mail.gmail.com>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com> <20170224230333.GA58409@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33465 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751424AbdBYA0N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 19:26:13 -0500
Received: by mail-wm0-f68.google.com with SMTP id v77so5221531wmv.0
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 16:26:12 -0800 (PST)
In-Reply-To: <20170224230333.GA58409@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 24, 2017 at 6:03 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Wed, Feb 22, 2017 at 11:38:49AM -0500, Willem de Bruijn wrote:
>>
>> * Limitations / Known Issues
>>
>> - PF_INET6 is not yet supported.
>
> we struggled so far to make it work in our setups which are ipv6 only.
> Looking at patches it seems the code should just work.
> What particularly is missing ?
>
> Great stuff. Looking forward to net-next reopening :)

Thanks for taking the feature for a spin!

The udp and raw paths require separate ipv6 patches. TCP should indeed
just work. I just ran a slightly modified snd_zerocopy_lo with good
results as well as a hacked netperf to another host.

I should have had ipv6 from the start, of course. Will add it before
resubmitting when net-next opens. For now, quick hack to
snd_zerocopy_lo.c:

diff --git a/tools/testing/selftests/net/snd_zerocopy_lo.c
b/tools/testing/selftests/net/snd_zerocopy_lo.c
index 309b016a4fd5..38a165e2af64 100644
--- a/tools/testing/selftests/net/snd_zerocopy_lo.c
+++ b/tools/testing/selftests/net/snd_zerocopy_lo.c
@@ -453,7 +453,7 @@ static int do_setup_rx(int domain, int type, int protocol)

 static void do_setup_and_run(int domain, int type, int protocol)
 {
-       struct sockaddr_in addr;
+       struct sockaddr_in6 addr;
        socklen_t alen;
        int fdr, fdt, ret;

@@ -468,8 +468,8 @@ static void do_setup_and_run(int domain, int type,
int protocol)

        if (domain != PF_PACKET) {
                memset(&addr, 0, sizeof(addr));
-               addr.sin_family = AF_INET;
-               addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
+               addr.sin6_family = AF_INET6;
+               addr.sin6_addr = in6addr_loopback;
                alen = sizeof(addr);

                if (bind(fdr, (void *) &addr, sizeof(addr)))
@@ -589,7 +589,7 @@ int main(int argc, char **argv)
        if (cfg_test_raw_hdrincl)
                do_setup_and_run(PF_INET, SOCK_RAW, IPPROTO_RAW);
        if (cfg_test_tcp)
-               do_setup_and_run(PF_INET, SOCK_STREAM, 0);
+               do_setup_and_run(PF_INET6, SOCK_STREAM, 0);


Loopback zerocopy is disabled in RFCv2, so to use snd_zerocopy_lo to verify the
feature requires this hack in skb_orphan_frags_rx:

 static inline int skb_orphan_frags_rx(struct sk_buff *skb, gfp_t gfp_mask)
 {
-       if (likely(!skb_zcopy(skb)))
-               return 0;
-       return skb_copy_ubufs(skb, gfp_mask);
+       return skb_orphan_frags(skb, gfp_mask);
 }

With this change, I see

$ ./snd_zerocopy_lo_ipv6 -t
test socket(10, 1, 0)
cpu: 23
rx=106364 (6637 MB) tx=106364 txc=0
rx=209736 (13088 MB) tx=209736 txc=0
rx=314524 (19627 MB) tx=314524 txc=0
rx=419424 (26174 MB) tx=419424 txc=0
OK. All tests passed

$ ./snd_zerocopy_lo_ipv6 -t -z
test socket(10, 1, 0)
cpu: 23
rx=239792 (14964 MB) tx=239792 txc=239786
rx=477376 (29790 MB) tx=477376 txc=477370
rx=715016 (44620 MB) tx=715016 txc=715010
rx=952820 (59460 MB) tx=952820 txc=952814
OK. All tests passed

In comparison, the same without the change

$ ./snd_zerocopy_lo_ipv6 -t
test socket(10, 1, 0)
cpu: 23
rx=109908 (6858 MB) tx=109908 txc=0
rx=217100 (13548 MB) tx=217100 txc=0
rx=326584 (20380 MB) tx=326584 txc=0
rx=429568 (26807 MB) tx=429568 txc=0
OK. All tests passed

$ ./snd_zerocopy_lo_ipv6 -t  -z
test socket(10, 1, 0)
cpu: 23
rx=87636 (5468 MB) tx=87636 txc=87630
rx=174328 (10878 MB) tx=174328 txc=174322
rx=260360 (16247 MB) tx=260360 txc=260354
rx=346512 (21623 MB) tx=346512 txc=346506

Here the sk_buff hits the deep copy in skb_copy_ubufs called from
__netif_receive_skb_core, which actually degrades performance versus
copying as part of the sendmsg() syscall.

The netperf change is to add MSG_ZEROCOPY to send() in send_tcp_stream
and also adding a recvmsg(send_socket, &msg, MSG_ERRQUEUE) to the same
function, preferably called only once every N iterations. This does
not take any additional explicit references on the send_ring element
while data is in flight, so is really a hack, but ring contents should
be static throughout the test. I did not modify the omni tests, so
this requires building with --no-omni.
