From: Dave Jones <davej@redhat.com>
Subject: out of bounds writes in net/hsr/
Date: Mon, 3 Mar 2014 22:27:57 -0500
Message-ID: <20140304032757.GA19048@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: arvid.brodin@xdin.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61480 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756022AbaCDD2O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2014 22:28:14 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I found this in coverity, and I think it's a real bug..

hsr_register_frame_in does a check that dev_idx is between 0 and 2,
therefore, a dev_idx of 2 is possible when it gets to the array writes
at the end of the function.  The arrays are defined such..

 26 struct node_entry {
...
 33         unsigned long   time_in[HSR_MAX_SLAVE];
 34         bool            time_in_stale[HSR_MAX_SLAVE];

and HSR_MAX_SLAVE is...

139 enum hsr_dev_idx {
140         HSR_DEV_NONE = -1,
141         HSR_DEV_SLAVE_A = 0,
142         HSR_DEV_SLAVE_B,
143         HSR_DEV_MASTER,
144 };
145 #define HSR_MAX_SLAVE   (HSR_DEV_SLAVE_B + 1)

So we have arrays of 2 bytes, and we can try to write to the 3rd byte.

The problem seems to be that the checking in hsr_register_frame is on
HSR_MAX_DEV which is defined as..

#define HSR_MAX_DEV     (HSR_DEV_MASTER + 1)

The + 1 seems odd, and looking at the other uses of HSR_MAX_DEV, I can't
figure out why it's there.

	Dave
