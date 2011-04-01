From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/7] Initialize flowi4 objects more efficiently.
Date: Thu, 31 Mar 2011 17:12:08 -0700 (PDT)
Message-ID: <20110331.171208.115926499.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56966
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753464Ab1DAAMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 20:12:46 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 15EF224C089
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2011 17:12:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When you do an initialization of an on-stack object such as:

	struct foo x = { .member1 = bar, .member2 = baz };

GCC will emit a memset of the object, then fill in the parameters you
specify explicitly.

When the majority of the structure is being set explicitly, the memset
is basically unnecessary overhead.  Emitting explicit stores to fill
in the zeros would be much cheaper, as well as avoid the function call
to memset.

Fix this for the cases which initialize most of the flowi4 object.

I therefore left alone cases such as:

	struct flowi4 fl4 = { .daddr = daddr };

Since not only would any gains be minimal, we'd get code bloat and
much of such cases are also in the slow paths.
