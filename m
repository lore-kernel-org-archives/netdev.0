From: Dave Jones <davej@redhat.com>
Subject: kmemleak reports firmware loader funnies in iwlwifi
Date: Fri, 26 Jun 2009 13:19:33 -0400
Message-ID: <20090626171933.GA23170@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Catalin Marinas <catalin.marinas@arm.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:57934 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754546AbZFZRTh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2009 13:19:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After enabling kmemleak in the Fedora rawhide kernels, we've mostly
seen a flood of what appear to be false positives, but the below looks
really suspect..

https://bugzilla.redhat.com/show_bug.cgi?id=507971

Here's the summary... 


iwlagn 0000:03:00.0: loaded firmware version 8.24.2.12
kmemleak: Freeing unknown object at 0xffffc90018070000
Pid: 1034, comm: NetworkManager Not tainted 2.6.31-0.25.rc0.git22.fc12.x86_64
#1
Call Trace:
 [<ffffffff81139f74>] delete_object+0x5b/0x13b
 [<ffffffff8113b012>] kmemleak_free+0x5b/0xb5
 [<ffffffff8111dc51>] vfree+0x40/0x68
 [<ffffffff813485e6>] release_firmware+0x49/0x6c
 [<ffffffffa021997c>] ? iwl_mac_start+0xc5c/0x106b [iwlagn]
 [<ffffffffa0219adc>] iwl_mac_start+0xdbc/0x106b [iwlagn]
 [<ffffffff8109df9b>] ? __module_text_address+0x25/0x85


So it appears to be vfree'ing something that it had no knowledge of ever allocating.
afaict _request_firmware only vmallocs when it's using a firmware image built into
the driver, which isn't the case here, so I'm not sure why we end up trying
to vfree instead of kfree when we call release_firmware

anyone know what's going on here?

	Dave
