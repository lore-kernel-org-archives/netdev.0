From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH] net-packet: tx timestamping on tpacket ring
Date: Mon, 15 Apr 2013 12:59:26 -0400
Message-ID: <CA+FuTSdGdhgpRARbv9zFnDESzCQBzT=DS-WgGZRWBLBvhN_sNg@mail.gmail.com>
References: <CA+FuTSezggEb7znDYMf8vWU7JmWLP59AVPkaTvNaAwJoNcqk9A@mail.gmail.com>
 <1365879412-9541-1-git-send-email-willemb@google.com> <5169D9C8.8010504@redhat.com>
 <CA+FuTSe1KCPPW=FBXZoTNmri9oPHicuoFeEMKws09PwbyRe-2A@mail.gmail.com>
 <516A8A60.5020003@redhat.com> <20130414130726.GB2871@netboy> <516BAE3A.5020508@onera.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Richard Cochran <richardcochran@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	daniel.borkmann@tik.ee.ethz.ch, xemul@parallels.com,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: Paul Chavent <Paul.Chavent@onera.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f177.google.com ([209.85.210.177]:39162 "EHLO
	mail-ia0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752249Ab3DOQ74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 12:59:56 -0400
Received: by mail-ia0-f177.google.com with SMTP id w33so4575374iag.36
        for <netdev@vger.kernel.org>; Mon, 15 Apr 2013 09:59:56 -0700 (PDT)
In-Reply-To: <516BAE3A.5020508@onera.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 15, 2013 at 3:37 AM, Paul Chavent <Paul.Chavent@onera.fr> wrote:
>
>
> On 04/14/2013 03:07 PM, Richard Cochran wrote:
>>
>> On Sun, Apr 14, 2013 at 12:52:16PM +0200, Daniel Borkmann wrote:
>>>
>>>
>>> While going a bit more through the code, I'm wondering .. if we want to
>>> support
>>> TX timestamps, could we also support SW _and_ HW timestamps e.g. similar
>>> as in
>>> sock_recv_timestamp()? I'm asking, because we already allow setting the
>>> flags
>>> for it via sock_tx_timestamp(). This might be good, if possible.
>>
>>
>> And while you are at it, you could also fix the receive code.
>>
>> As it stand now, it is fairly useless, since there is no way for user
>> space to tell which kind of time stamp has been reported. In fact, the
>> code will silently intermingle hardware and software time stamps. That
>> is surely a mean trick to play on the users.

Interesting issue, but I'll leave that for a separate fix.
>
> Isn't it the one that the user ask with setsockopt(fd, SOL_PACKET,
> PACKET_TIMESTAMP, &timestamping, sizeof(timestamping)) ?

This option toggles whether, if an skbuff has a timestamp, it should
be written to the rx ring metadata. skbuffs can have multiple
timestamps, so it also determines which one is selected.

If I understand correctly, the problem that Richard refers to is that
when one socket requests rx timestamping, all rx skbuffs have to be
timestamped as it is not known early in the datapath to which socket
they will be enqueued. As a result, the timestamps in skbuffs depend
on the preferences of other active sockets. Correct me if I'm wrong.

If so, it may even vary during the lifetime of a packet socket, so a
getsockopt wouldn't help, either. Perhaps nothing short of a new field
in the frame header structure will. In which case it makes more sense
to support sending each type of timestamp independently, just like the
socker error queue mechanism. Adding yet another header format,
though?

> However, i wonder why you added an other sockopt that do the same thing as
> SOL_SOCKET/SO_TIMESTAMPING sockopt ?

Back to the patch. I'll revise with

- a small patch for the errqueue mechanism
  - add hw timestamp pass-through in skb_tstamp_tx, if correct
  - move sock_tx_timestamp where cache is warm
  - update it to use only a single conditional in the common case: no
flags enabled

- a follow-up for the ring
  - single flush_dcache_page, which is safe for current header layouts
on 32bit+ platforms
    (it is also a noop on many of these)
