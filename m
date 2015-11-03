From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH v2 net-next] net/core: generic support for disabling
 netdev features down stack
Date: Tue, 3 Nov 2015 14:52:44 +0100
Message-ID: <CAMuHMdXrs2fkHw+DGgutM1y71Y=MTsxSqJ+J78e_Q7oZjaNesA@mail.gmail.com>
References: <1446486818-26166-1-git-send-email-jarod@redhat.com>
	<1446519359-21400-1-git-send-email-jarod@redhat.com>
	<5638865D.2000804@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jarod Wilson <jarod@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Michal Kubecek <mkubecek@suse.cz>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34113 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752330AbbKCNwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 08:52:45 -0500
In-Reply-To: <5638865D.2000804@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 3, 2015 at 11:03 AM, Nikolay Aleksandrov
<nikolay@cumulusnetworks.com> wrote:
> On 11/03/2015 03:55 AM, Jarod Wilson wrote:
> [snip]
>>
>> +#define for_each_netdev_feature(mask_addr, feature)                          \
>> +     int bit;                                                                \
>> +     for_each_set_bit(bit, (unsigned long *)mask_addr, NETDEV_FEATURE_COUNT) \
>> +             feature = __NETIF_F_BIT(bit);
>> +
> ^
> This is broken, it will not work for more than a single feature.

Indeed it is.

This is used as:

        for_each_netdev_feature(&upper_disables, feature) {
        ...
        }

which expands to:

        int bit;
        for_each_set_bit(bit, (unsigned long *)mask_addr, NETDEV_FEATURE_COUNT)
                feature = __NETIF_F_BIT(bit);
        {
                ...
        }

Note the assignment to "feature" happens outside the {}-delimited block.
And the block is always executed once.

Interestingly, arm-unknown-linux-gnueabi-gcc 4.9.0 warns about this in
some of my configs, but not in all of them:

net/core/dev.c: In function '__netdev_update_features':
net/core/dev.c:6302:16: warning: 'feature' may be used uninitialized
in this function [-Wmaybe-uninitialized]
    features &= ~feature;
                ^
net/core/dev.c:6295:20: note: 'feature' was declared here
  netdev_features_t feature;
                    ^
Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
