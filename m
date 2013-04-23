From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next 5/5] packet: doc: update timestamping part
Date: Tue, 23 Apr 2013 08:20:19 -0400
Message-ID: <CA+FuTSdoExuure7a2XPnVwP0VZS-YOrVjVEUWxe02_SeYZPi2Q@mail.gmail.com>
References: <1366713572-11978-1-git-send-email-dborkman@redhat.com> <1366713572-11978-6-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Paul Chavent <Paul.Chavent@onera.fr>,
	Richard Cochran <richardcochran@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f171.google.com ([209.85.210.171]:60287 "EHLO
	mail-ia0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754597Ab3DWMUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 08:20:52 -0400
Received: by mail-ia0-f171.google.com with SMTP id r13so337429iar.30
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 05:20:51 -0700 (PDT)
In-Reply-To: <1366713572-11978-6-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 23, 2013 at 6:39 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> Bring the timestamping section in sync with the implementation.
>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Willem de Bruijn <willemb@google.com>
> ---
>  Documentation/networking/packet_mmap.txt | 41 +++++++++++++++++++++++++++-----
>  1 file changed, 35 insertions(+), 6 deletions(-)
>
> diff --git a/Documentation/networking/packet_mmap.txt b/Documentation/networking/packet_mmap.txt
> index 65efb85..23dd80e 100644
> --- a/Documentation/networking/packet_mmap.txt
> +++ b/Documentation/networking/packet_mmap.txt
> @@ -1016,10 +1016,11 @@ retry_block:
>  -------------------------------------------------------------------------------
>
>  The PACKET_TIMESTAMP setting determines the source of the timestamp in
> -the packet meta information.  If your NIC is capable of timestamping
> -packets in hardware, you can request those hardware timestamps to used.
> -Note: you may need to enable the generation of hardware timestamps with
> -SIOCSHWTSTAMP.
> +the packet meta information for mmap(2)ed RX_RING and TX_RINGs.  If your
> +NIC is capable of timestamping packets in hardware, you can request those
> +hardware timestamps to be used. Note: you may need to enable the generation
> +of hardware timestamps with SIOCSHWTSTAMP (see related information from
> +Documentation/networking/timestamping.txt).
>
>  PACKET_TIMESTAMP accepts the same integer bit field as
>  SO_TIMESTAMPING.  However, only the SOF_TIMESTAMPING_SYS_HARDWARE
> @@ -1031,8 +1032,36 @@ SOF_TIMESTAMPING_RAW_HARDWARE if both bits are set.
>      req |= SOF_TIMESTAMPING_SYS_HARDWARE;
>      setsockopt(fd, SOL_PACKET, PACKET_TIMESTAMP, (void *) &req, sizeof(req))
>
> -If PACKET_TIMESTAMP is not set, a software timestamp generated inside
> -the networking stack is used (the behavior before this setting was added).
> +For the mmap(2)ed ring buffers, such timestamps are stored in the
> +tpacket{,2,3}_hdr structure's tp_sec and tp_{n,u}sec members. To determine
> +what kind of timestamp has been reported, the tp_status field is binary |'ed
> +with the following possible bits ...
> +
> +    TP_STATUS_TS_SYS_HARDWARE
> +    TP_STATUS_TS_RAW_HARDWARE
> +    TP_STATUS_TS_SOFTWARE
> +
> +... that are equivalent to its SOF_TIMESTAMPING_* counterparts. For the
> +RX_RING, if none of those 3 are set (i.e. PACKET_TIMESTAMP is not set),
> +then this means that a software fallback was invoked *within* PF_PACKET's
> +processing code (less precise).
> +
> +Getting timestamps for the TX_RING works as follows: i) fill the ring frames,
> +ii) call sendto() e.g. in blocking mode, iii) wait for status of relevant
> +frames to be updated resp. the frame handed over to the application, iv) walk
> +through the frames to pick up the individual hw/sw timestamps.
> +
> +Only (!) if transmit timestamping is enabled, then these bits are combined
> +with binary | with TP_STATUS_AVAILABLE, so you must check for that in your
> +application (e.g. !(tp_status & (TP_STATUS_SEND_REQUEST | TP_STATUS_SENDING))
> +in a first step to see if the frame belongs to the application, and then
> +one can extract the type of timestamp in a second step from tp_status)!
> +
> +If you don't care about them, thus having it disabled, checking for
> +TP_STATUS_AVAILABLE resp. TP_STATUS_WRONG_FORMAT is sufficient. If in the
> +TX_RING part only TP_STATUS_AVAILABLE is set, then the tp_sec and tp_{n,u}sec
> +members do not contain a valid value. For TX_RINGs, by default no timestamp
> +is generated!
>
>  See include/linux/net_tstamp.h and Documentation/networking/timestamping
>  for more information on hardware timestamps.
> --
> 1.7.11.7
>
