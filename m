From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH v2 net-next 0/2] net: print net_device name/state more
 often
Date: Thu, 17 Jul 2014 17:24:18 +0200
Message-ID: <20140717152418.GC28357@mikrodark.usersys.redhat.com>
References: <1405606186-13703-1-git-send-email-vfalico@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D17276E6E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Baron <jbaron@akamai.com>,
	Eric Dumazet <edumazet@google.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	stephen hemminger <stephen@networkplumber.org>,
	Jerry Chu <hkchu@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Tom Gundersen <teg@jklm.no>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:41771 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933680AbaGQP1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 11:27:17 -0400
Received: by mail-wi0-f173.google.com with SMTP id f8so6937983wiw.0
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2014 08:27:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17276E6E@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 17, 2014 at 02:48:17PM +0000, David Laight wrote:
>From: Veaceslav Falico
>> Currently we use net_device->name only if it's the NETREG_REGISTERED
>> reg_state, otherwise we return "(unregistered device)".
>>
>> However, we always populate net_device->name on creation, so it's always
>> available to us for use. The only caveat is that we might have a name like
>> "eth%d", in which case we cannot use it as it might change in the future.
>
>While you've got this code out on the operating table what about:

I don't think these ideas fit into the current patchset, as it's somehow
unrelated to the "lets give the real name/state when possible".

However, I like them, see below.

>1) Tracing the renames into the kernel message buffer.

I think you can enable it already. dev_change_name() (net's function to
change net_device name) calls device_rename(), which handles the device
renaming, and it has:

1805         dev_dbg(dev, "renaming to %s\n", new_name);

It can be easily enabled if you have dynamic debug compiled in.

However, indeed, it might be a good info to watch for, and a pretty simple
patch, which might be useful.

diff --git a/net/core/dev.c b/net/core/dev.c
index 239722a..d14ebf0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1113,6 +1113,9 @@ int dev_change_name(struct net_device *dev, const char *newname)
 		return err;
 	}
 
+	if (oldname[0] && !strchr(oldname, '%'))
+		netdev_info(dev, "renamed from %s\n", oldname);
+
 	old_assign_type = dev->name_assign_type;
 	dev->name_assign_type = NET_NAME_RENAMED;
 

>2) Including the original name in some of the kernel traces.

The only possible use-case of that, from what I can see (with the patch
from 1) ) - is in the renaming functions themselves, which have already
quite a few output sources and, tbh, it's a really rare situation to
implenment tracking of renames in-kernel.

>
>I've been trying to diagnose some issues on a system that renames
>its interfaces, and it can get tricky working out which interface
>messages refer to.
>
>	David
>
>
>
