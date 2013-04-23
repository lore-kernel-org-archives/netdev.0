From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next 0/5] PF_PACKET timestamping updates
Date: Tue, 23 Apr 2013 08:33:50 -0400
Message-ID: <CA+FuTSdKPJ0wQUoAKGAh4t=cKs=GQx0tymd8a93GwFGjdB6oAg@mail.gmail.com>
References: <1366713572-11978-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Paul Chavent <Paul.Chavent@onera.fr>,
	Richard Cochran <richardcochran@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:49565 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755000Ab3DWMeV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 08:34:21 -0400
Received: by mail-ie0-f175.google.com with SMTP id a11so576687iee.6
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 05:34:21 -0700 (PDT)
In-Reply-To: <1366713572-11978-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 23, 2013 at 6:39 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> This is a joint effort with Willem to bring optional i) tx hw/sw
> timestamping into PF_PACKET, that was reported by Paul Chavent,
> and ii) to expose the type of timestamp to the user, which is in
> the current situation not possible to distinguish with the RX_RING
> and TX_RING API (but distinguishable through the normal timestamping
> API), reported by Richard Cochran.

Does this solve the issue you raised, Richard? The patch does not
change which timestamp is written, so the ring will still fall back on
software if a hardware timestamp is unavailable. It now reports this
to the application in tp_status, however, so that it can act
accordingly (worst case: ignore the timestamp).

Unless packet-level timestamping is explicitly enabled, nothing
changes. The feature is new on tx, so there are no tx legacy concerns
for tp_status. On rx, without timestamping, tp_status bit is similarly
unaltered. Only applications that have receive timestamping enabled on
rx will see a different tp_status field. This would break applications
that test (tp_status == TP_STATUS_USER) as opposed to (tp_status &
TP_STATUS_USER). That behavior is incorrect. I'm just not sure whether
it exists.

> This set is based on top of
> ``packet: account statistics only in tpacket_stats_u''. Related
> discussion can be found in: http://patchwork.ozlabs.org/patch/238125/
>
> Daniel Borkmann (4):
>   packet: enable hardware tx timestamping on tpacket ring
>   packet: minor: convert status bits into shifting format
>   packet: if hw/sw ts enabled in rx/tx ring, report which ts we got
>   packet: doc: update timestamping part

Thanks for looking into this, Daniel!

> Willem de Bruijn (1):
>   packet: tx timestamping on tpacket ring
>
>  Documentation/networking/packet_mmap.txt | 41 ++++++++++++---
>  include/uapi/linux/if_packet.h           | 27 ++++++----
>  net/core/skbuff.c                        | 12 ++---
>  net/packet/af_packet.c                   | 87 ++++++++++++++++++++++++--------
>  4 files changed, 122 insertions(+), 45 deletions(-)
>
> --
> 1.7.11.7
>
