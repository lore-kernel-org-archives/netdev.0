From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 0/5] PF_PACKET timestamping updates
Date: Tue, 23 Apr 2013 14:53:03 +0200
Message-ID: <5176842F.7040703@redhat.com>
References: <1366713572-11978-1-git-send-email-dborkman@redhat.com> <CA+FuTSdKPJ0wQUoAKGAh4t=cKs=GQx0tymd8a93GwFGjdB6oAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Paul Chavent <Paul.Chavent@onera.fr>,
	Richard Cochran <richardcochran@gmail.com>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4029 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755991Ab3DWMx1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Apr 2013 08:53:27 -0400
In-Reply-To: <CA+FuTSdKPJ0wQUoAKGAh4t=cKs=GQx0tymd8a93GwFGjdB6oAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/2013 02:33 PM, Willem de Bruijn wrote:
> On Tue, Apr 23, 2013 at 6:39 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> This is a joint effort with Willem to bring optional i) tx hw/sw
>> timestamping into PF_PACKET, that was reported by Paul Chavent,
>> and ii) to expose the type of timestamp to the user, which is in
>> the current situation not possible to distinguish with the RX_RING
>> and TX_RING API (but distinguishable through the normal timestamping
>> API), reported by Richard Cochran.
>
> Does this solve the issue you raised, Richard? The patch does not
> change which timestamp is written, so the ring will still fall back on
> software if a hardware timestamp is unavailable. It now reports this
> to the application in tp_status, however, so that it can act
> accordingly (worst case: ignore the timestamp).

Well, for the {RX,TX}_RING there is really no other way except the really
really ugly possibility to introduce yet another tpacket header with 3
time-stamp fields (sw, sys, raw). I really do not like that. :-)

At least here, if you have traffic from different devices, you either get
what you want (e.g. hw ts), or you'll get a fallback sw ts. That is also
the case in the current code without this patchset. At least this set would
solve this issue of telling the user what ts source he sees.

> Unless packet-level timestamping is explicitly enabled, nothing
> changes. The feature is new on tx, so there are no tx legacy concerns
> for tp_status. On rx, without timestamping, tp_status bit is similarly
> unaltered. Only applications that have receive timestamping enabled on
> rx will see a different tp_status field. This would break applications
> that test (tp_status == TP_STATUS_USER) as opposed to (tp_status &
> TP_STATUS_USER). That behavior is incorrect. I'm just not sure whether
> it exists.

Right, this would actually be broken, since tp_status == TP_STATUS_USER
would filter out packets where also other bits are set as given in
include/uapi/linux/if_packet.h +88 . Neither kernel checks with == nor,
libpcap (just checked their code). E.g. libpcap checks if
h.h{1,2}->tp_status != 0, then it must be TP_STATUS_USER, else
TP_STATUS_KERNEL in pcap-linux.c +3757.

>> This set is based on top of
>> ``packet: account statistics only in tpacket_stats_u''. Related
>> discussion can be found in: http://patchwork.ozlabs.org/patch/238125/
>>
>> Daniel Borkmann (4):
>>    packet: enable hardware tx timestamping on tpacket ring
>>    packet: minor: convert status bits into shifting format
>>    packet: if hw/sw ts enabled in rx/tx ring, report which ts we got
>>    packet: doc: update timestamping part
>
> Thanks for looking into this, Daniel!
>
>> Willem de Bruijn (1):
>>    packet: tx timestamping on tpacket ring
>>
>>   Documentation/networking/packet_mmap.txt | 41 ++++++++++++---
>>   include/uapi/linux/if_packet.h           | 27 ++++++----
>>   net/core/skbuff.c                        | 12 ++---
>>   net/packet/af_packet.c                   | 87 ++++++++++++++++++++++++--------
>>   4 files changed, 122 insertions(+), 45 deletions(-)
