From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH] packet: Allow packets with only a header (but no payload)
Date: Mon, 9 Nov 2015 12:53:48 -0500
Message-ID: <CA+FuTSf50B7EbQpPjMYZc_a8aeqPLb+nUHHTTsASkBRWpr7PGw@mail.gmail.com>
References: <1437495247-471-1-git-send-email-martin.blumenstingl@googlemail.com>
 <CA+FuTScr0o0ZmwWxVP4FZoQosRRiQG6+MDvCahMCWmjLkg+33g@mail.gmail.com>
 <CAFBinCB4xOBzxwkEQYrpi1q7Xm4_-hpj2jUE2r-fQ5f2grjZ=Q@mail.gmail.com>
 <CA+FuTSctXr=2eC_-e793hvAPu=XyEhLeLoowH95tbOBx8CGj7g@mail.gmail.com>
 <CAFBinCDZDYJGjimsAD=+HFokc9ga0cLBD1KSAieagzWQNH+s=w@mail.gmail.com>
 <CA+FuTSfw+-6Xb_0xchM5E6vCMSsyiSvSYF3MbuE25pEt07RRbw@mail.gmail.com>
 <CAFBinCBYv44ttGNyny11gEwNMJDwYzO=YYJC5scwOE-PN2nn4A@mail.gmail.com> <563DF875.7090104@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
	Network Development <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>, johann.baudy@gnu-log.net,
	paulus@samba.org, Daniel Borkmann <daniel@iogearbox.net>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f174.google.com ([209.85.160.174]:35515 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691AbbKIRyT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 12:54:19 -0500
Received: by ykek133 with SMTP id k133so278220604yke.2
        for <netdev@vger.kernel.org>; Mon, 09 Nov 2015 09:54:19 -0800 (PST)
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com. [209.85.160.178])
        by smtp.gmail.com with ESMTPSA id p202sm3807499ywe.44.2015.11.09.09.54.18
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 09:54:18 -0800 (PST)
Received: by ykdr82 with SMTP id r82so2921824ykd.3
        for <netdev@vger.kernel.org>; Mon, 09 Nov 2015 09:54:17 -0800 (PST)
In-Reply-To: <563DF875.7090104@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 7, 2015 at 8:11 AM, Felix Fietkau <nbd@openwrt.org> wrote:
> On 2015-07-31 00:15, Martin Blumenstingl wrote:
>> On Wed, Jul 29, 2015 at 8:05 AM, Willem de Bruijn <willemb@google.co=
m> wrote:
>>> Martin, to return to your initial statement that PPPoE PADI packets=
 can
>>> have a zero payload: the PPPoE RFC states that PADI packets "MUST
>>> contain exactly one TAG of TAG_TYPE Service-Name, indicating the
>>> service the Host is requesting, and any number of other TAG types."
>>> (RFC 2516, 5.1). Is the observed behavior (no payload) perhaps
>>> incorrect?
>> As far as I can see you are right, but the real world seems to be di=
fferent.
>> My ISP for example lists the PPPoE connection settings, but they are
>> nowhere mentioning the "service name".
>>
>> I have also re-read pppd's source code again and that seems to confi=
rm
>> what you are reading in the RFC: Leaving the service name away makes
>> seems to violate the RFC, but pppd still accepts those configuration=
s.
>>
>>> Even if it is, if this is breaking established userspace expectatio=
ns,
>>> we should look into it. Ethernet specifies a minimum payload size o=
f
>>> 46 on the wire, but perhaps that is handled with padding, so that
>>> 0 length should be valid within the stack. Also, there may be other
>>> valid uses of 0 length payload on top of link layers that are not E=
thernet.
>> Good catch. I would also like to note that the documentation for
>> "hard_header_len" describes it as "Hardware header length". When the
>> purpose of this field we should check whether the documentation shou=
ld
>> be updated to "Minimum hardware header length" -> that would mean th=
e
>> condition has to be a "len < hard_header_len" instead of a "len <=3D
>> hard_header_len" (as it is now).
>>
>> PS: I have also added the pppd maintainer (Paul Mackerras) to this
>> thread because I think he should know about this issue (and he can
>> probably provide more details if required).
>> As a quick summary for him: linux  >=3D 3.19 rejects PADI packets wh=
en
>> no service name is configured.
> Any news on this? Users are complaining about this regression:
> https://dev.openwrt.org/ticket/20707

I took another look. This hinges on the question what the contract with
device drivers is on skb network data and length. Is passing an skb wit=
h
skb->len =3D=3D 0 to ndo_start_xmit allowed?

=46rom what I gather from the ethernet spec [1], sending frames with an
empty head is allowed on that medium, at least.

A quick scan of a few drivers and the loopback path also does not show
anything that would break. In some cases, skb_network_header points
beyond the end of the buffer (ETH_HLEN), but the length is correctly
reported as 0.

The tap device can also generate packets consisting of only a link laye=
r
header: compares len < ETH_HLEN in tun_get_user.

So, I think that this change should be correct:

 static bool ll_header_truncated(const struct net_device *dev, int len)
 {
-       /* net device doesn't like empty head */
-       if (unlikely(len <=3D dev->hard_header_len)) {
+       if (unlikely(len < dev->hard_header_len)) {

but a definitive answer would require an audit of all device drivers
(including bonding, ..) or at least the certainty that it has always
been correct to send a packet of only link layer header to
ndo_start_xmit.

[1] IEEE 802.3=E2=84=A2-2012 =E2=80=93 Section One, {3.2.8, 4.2.3.3}
