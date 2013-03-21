From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next] net: fix psock_fanout selftest hash collision
Date: Thu, 21 Mar 2013 13:27:51 -0400
Message-ID: <CA+FuTSfkxkbZ8N1Vr2NVmT-8Obd2sGAo2a_Wwv=U-4KPvnLPPA@mail.gmail.com>
References: <CA+FuTSeN1wXrSP8-piCdnv8MuqgokndSYsiidvdtC=d2tCqcDQ@mail.gmail.com>
 <1363761764-4374-1-git-send-email-willemb@google.com> <20130320.123344.1566685302188091721.davem@davemloft.net>
 <20130320.135934.156565403641352244.davem@davemloft.net> <CA+FuTScnkvSZ1U=vmELNEpS4hU62iMV7B2ZDHT8KGAwxCxA-Ng@mail.gmail.com>
 <514AA946.6020603@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:55209 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324Ab3CUR2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 13:28:22 -0400
Received: by mail-ie0-f176.google.com with SMTP id x14so3762223ief.21
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 10:28:22 -0700 (PDT)
In-Reply-To: <514AA946.6020603@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 21, 2013 at 2:31 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 03/21/2013 01:07 AM, Willem de Bruijn wrote:
>>
>> On Wed, Mar 20, 2013 at 1:59 PM, David Miller <davem@davemloft.net> wrote:
>>>
>>> From: David Miller <davem@davemloft.net>
>>> Date: Wed, 20 Mar 2013 12:33:44 -0400 (EDT)
>>>
>>>> From: Willem de Bruijn <willemb@google.com>
>>>> Date: Wed, 20 Mar 2013 02:42:44 -0400
>>>>
>>>>> Fix flaky results with PACKET_FANOUT_HASH depending on whether the
>>>>> two flows hash into the same packet socket or not.
>>>>>
>>>>> Also adds tests for PACKET_FANOUT_LB and PACKET_FANOUT_CPU and
>>>>> replaces the counting method with a packet ring.
>>>>>
>>>>> Signed-off-by: Willem de Bruijn <willemb@google.com>
>>>>
>>>>
>>>> Applied, thanks.  I'll retest on my sparc64 box later today.
>>>
>>>
>>> Unfortunately, it's still broken there:
>>
>>
>> This looks like a new problem. Now the counters all stay zero.
>>
>> I am looking into it. I have not been able to reproduce this on my
>> x86_64 so far, so just brought a sparc32 up in qemu. Had less luck
>> with sparc64, but impressive that it works at all. Come to think of
>> it, is this a 64-bit kernel with 32-bit userland? Perhaps that
>> affects packet ring memory layout.
>
>
> That can affect the ring buffer in case of TPACKET_V1, which is default
> if not specified otherwise. See Documentation/networking/packet_mmap.txt
> +514

Thanks, Daniel. In that case, the following should fix it.
Unfortunately, I don't have the hardware to verify, but it still
passes on my platforms. Let me know if you prefer it as a regular
patch instead of inline.

diff --git a/tools/testing/selftests/net/psock_fanout.c
b/tools/testing/selftests/net/psock_fanout.c
index 226e5e3..59bd636 100644
--- a/tools/testing/selftests/net/psock_fanout.c
+++ b/tools/testing/selftests/net/psock_fanout.c
@@ -182,7 +182,13 @@ static char *sock_fanout_open_ring(int fd)
                .tp_frame_nr   = RING_NUM_FRAMES,
        };
        char *ring;
+       int val = TPACKET_V2;

+       if (setsockopt(fd, SOL_PACKET, PACKET_VERSION, (void *) &val,
+                      sizeof(val))) {
+               perror("packetsock ring setsockopt version");
+               exit(1);
+       }
        if (setsockopt(fd, SOL_PACKET, PACKET_RX_RING, (void *) &req,
                       sizeof(req))) {
                perror("packetsock ring setsockopt");
@@ -201,7 +207,7 @@ static char *sock_fanout_open_ring(int fd)

 static int sock_fanout_read_ring(int fd, void *ring)
 {
-       struct tpacket_hdr *header = ring;
+       struct tpacket2_hdr *header = ring;
        int count = 0;

        while (header->tp_status & TP_STATUS_USER && count < RING_NUM_FRAMES) {
