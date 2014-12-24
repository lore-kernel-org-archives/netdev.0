From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net] net: Generalize ndo_gso_check to ndo_features_check
Date: Wed, 24 Dec 2014 00:11:42 -0500
Message-ID: <CAEP_g=81JfSJYh=Mct3bmHzsntL6aE2tj7T06Ac-NYVBzPAeFQ@mail.gmail.com>
References: <1419264223-30004-1-git-send-email-jesse@nicira.com> <20141223.235238.1958837159787674842.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>,
	Joe Stringer <joestringer@nicira.com>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog116.obsmtp.com ([74.125.149.240]:53822 "HELO
	na3sys009aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750977AbaLXFME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 00:12:04 -0500
Received: by mail-qg0-f44.google.com with SMTP id q107so5508002qgd.3
        for <netdev@vger.kernel.org>; Tue, 23 Dec 2014 21:12:02 -0800 (PST)
In-Reply-To: <20141223.235238.1958837159787674842.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 23, 2014 at 11:52 PM, David Miller <davem@davemloft.net> wrote:
> From: Jesse Gross <jesse@nicira.com>
> Date: Mon, 22 Dec 2014 08:03:43 -0800
>
>> GSO isn't the only offload feature with restrictions that
>> potentially can't be expressed with the current features mechanism.
>> Checksum is another although it's a general issue that could in
>> theory apply to anything. Even if it may be possible to
>> implement these restrictions in other ways, it can result in
>> duplicate code or inefficient per-packet behavior.
>>
>> This generalizes ndo_gso_check so that drivers can remove any
>> features that don't make sense for a given packet, similar to
>> netif_skb_features(). It also converts existing driver
>> restrictions to the new format, completing the work that was
>> done to support tunnel protocols since the issues apply to
>> checksums as well.
>>
>> CC: Tom Herbert <therbert@google.com>
>> CC: Joe Stringer <joestringer@nicira.com>
>> CC: Eric Dumazet <edumazet@google.com>
>> Signed-off-by: Jesse Gross <jesse@nicira.com>
>> Fixes: 04ffcb255f22 ("net: Add ndo_gso_check")
>
> I don't think this fixes the case which was the main impetus for Eric
> Dumazet's patch.
>
> The r8152 USB networking driver supports TSO, but has a length
> restriction, and we weren't software segmenting when netif_needs_gso()
> returns true, exactly because we didn't clear TSO from the feature
> flags.

I believe that this should behave exactly the same as Eric's patch in
this case. The driver would implement the length validation and return
the set of features with ANDed with ~NETIF_F_GSO_MASK. This is
combined with the features computed by netif_skb_features() used for
all future offload decisions, including skb_gso_segment().
