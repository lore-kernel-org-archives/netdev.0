From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [Bugme-new] [Bug 10737] New: pktgen procfs problem
Date: Mon, 19 May 2008 11:54:02 +0400
Message-ID: <1211183642.9966.6.camel@iris.sw.ru>
References: <bug-10737-10286@http.bugzilla.kernel.org/>
	 <20080517141036.d8f3c768.akpm@linux-foundation.org>
	 <482F88DE.8090508@trash.net>
	 <20080517215641.acb94677.akpm@linux-foundation.org>
	 <48301BE0.9040907@trash.net> <48302E09.8080701@trash.net>
	 <48304BB5.7090805@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-joy3Rkzz9a3O8bGzVoaI"
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, devzero@web.de,
	Robert Olsson <robert.olsson@its.uu.se>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Ben Greear <greearb@candelatech.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:37047 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751993AbYESHyg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2008 03:54:36 -0400
In-Reply-To: <48304BB5.7090805@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-joy3Rkzz9a3O8bGzVoaI
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 2008-05-18 at 17:31 +0200, Patrick McHardy wrote:
> Patrick McHardy wrote:
> >>>> I've been looking into the same problem, without much success so
> >>>> far. The problem appears to affect any /proc/net file, but not
> >>>> files outside of /proc/net, so I'm guessing its net-ns related.
> >>>> A testcase found by Ben Greear is opening the file multiple times:
> >>>>
> >>>> # /tmp/open /proc/net/kpktgen_0
> >>>>
> >>>> => refcnt goes to 1
> >>>>
> >>>> ^C
> >>>>
> >>>> => refcnt goes to 0
> >>>>
> >>>> Without ^C and opening the file a second time:
> >>>>
> >>>> # /tmp/open /proc/net/kpktgen_0
> >>>>
> >>>> => refcnt goes to 2 (sometimes also 11)
> >>>>
> >>>> ^C
> >>>>
> >>>> => refcnt stays at previous value.
> >>>>
> >>>> The refcnt even leaks if the file can't be successfully opened,
> >>>> for example because of lacking permissions.
> >>>>     
> >>>
> >>> urgh.  Is any of this known to be post-2.6.25?
> >>>   
> >>
> >> 2.6.25 is also affected. I don't know about earlier kernels.
> > 
> > Some more information: the problem seems to occur only if
> > the file is opened by two different processes.
> > 
> > I'm starting a bisection now.
> 
> 
> git-bisect identified e9720acd ([NET]: Make /proc/net a symlink
> on /proc/self/net (v3)) as the guilty commit. I couldn't find
> the problem in that commit, so someone with a better understanding
> of how this is supposed to work should look into it.

could you consider this preliminary patch? It fixes the problem for me
and Pavel agrees with it.

The problem is that module_get is called for each file opening while
module_put is called only when /proc inode is destroyed. So, lets put
module counter if we are dealing with already initialised inode.

--=-joy3Rkzz9a3O8bGzVoaI
Content-Disposition: attachment; filename=diff-procinode-count
Content-Type: text/x-patch; name=diff-procinode-count; charset=KOI8-R
Content-Transfer-Encoding: 7bit

diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index 6f4e8dc..b08d100 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -425,7 +425,8 @@ struct inode *proc_get_inode(struct super_block *sb, unsigned int ino,
 			}
 		}
 		unlock_new_inode(inode);
-	}
+	} else
+	       module_put(de->owner);
 	return inode;
 
 out_ino:

--=-joy3Rkzz9a3O8bGzVoaI--

