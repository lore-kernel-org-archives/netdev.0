From: David Miller <davem@davemloft.net>
Subject: ESP trailer_len calculation
Date: Fri, 24 Sep 2010 14:40:44 -0700 (PDT)
Message-ID: <20100924.144044.179940003.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45055
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758154Ab0IXVkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 17:40:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Eric Dumazet and I recently were looking into a strange artifact in
ESP ->trailer_len calculations.

Eric was seeing values like "17" which looked strange.

He foudn that it's because of this line in esp4.c:esp_init_state()

	x->props.trailer_len = align + 1 + crypto_aead_authsize(esp->aead);

which comes from commit:

commit c5c2523893747f88a83376abad310c8ad13f7197
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Apr 9 11:47:18 2007 -0700

    [XFRM]: Optimize MTU calculation

which is based upon discussion threads:

http://marc.info/?l=linux-netdev&m=115468159401118&w=2

and

http://marc.info/?l=linux-netdev&m=117561805827241&w=2

Even more strange, in the orignal version of this patch the
calcaluation is actually:

	x->props.trailer_len = align - 1 + esp->auth.icv_trunc_len;

(ie. 'align - 1' instead of 'align + 1')

It seems that this "- 1 " or "+ 1" term can be completely eliminated,
unless there are some funny semantics wrt. the padding area of ESP.

Patrick and Herbert, what do you guys think?
