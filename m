From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Broken link in /sys/class/net/ [was: [GIT] Networking]
Date: Sat, 29 Oct 2011 21:49:47 -0700
Message-ID: <m11utvytg4.fsf@fess.ebiederm.org>
References: <20111025.063206.2273357152859701628.davem@davemloft.net>
	<CA+55aFw1GVvszqoC_f0RAvG5t1xj0CSYLhLU=y0gQ+_54Gsomw@mail.gmail.com>
	<20111025131315.GA1899@suse.de> <4EAC8642.3050309@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh@suse.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Mikulas Patocka <mpatocka@redhat.com>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EAC8642.3050309@suse.cz> (Jiri Slaby's message of "Sun, 30 Oct
	2011 01:03:30 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Slaby <jslaby@suse.cz> writes:

> On 10/25/2011 03:13 PM, Greg KH wrote:
>> On Tue, Oct 25, 2011 at 01:46:11PM +0200, Linus Torvalds wrote:
>>> Anyway, after that rant about really bad practices, let me say that I
>>> did fix up the conflict and I think it's right. But I won't guarantee
>>> it, so please check the changes to fs/sysfs/dir.c.
>> 
>> I think it looks ok, I've booted the merge result, and am typing and
>> sending this from the new kernel, and it hasn't crashed yet :)
>
> Hi, maybe this was not caused by the merge, but the patch[1] causes this
> mess in /sys/class/net/ for me:
> l????????? ? ?    ?    ?             ? eth1
>
> This happens after one renames a net device -- the new name is eth1 here.
>
> [1] 4f72c0cab40 (sysfs: use rb-tree for name lookups)

This looks pretty fixable but today sysfs_rename does not do anything
with the to move a renamed entry to a different position in the rbtree.

If the directory itself changes sysfs_rename should be fine, and it
looks like a trivial patch to always apply the directory rename logic
in sysfs_rename. 

I think all we need is something like the untested patch below to fix
the network device rename problem.

Eric

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index 48ffbdf..a294068 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -865,14 +865,13 @@ int sysfs_rename(struct sysfs_dirent *sd,
 		sd->s_name = new_name;
 	}
 
-	/* Remove from old parent's list and insert into new parent's list. */
-	if (sd->s_parent != new_parent_sd) {
-		sysfs_unlink_sibling(sd);
-		sysfs_get(new_parent_sd);
-		sysfs_put(sd->s_parent);
-		sd->s_parent = new_parent_sd;
-		sysfs_link_sibling(sd);
-	}
+	/* Move to the appropriate place in the appropriate directories rbtree. */
+	sysfs_unlink_sibling(sd);
+	sysfs_get(new_parent_sd);
+	sysfs_put(sd->s_parent);
+	sd->s_parent = new_parent_sd;
+	sysfs_link_sibling(sd);
+
 	sd->s_ns = new_ns;
 
 	error = 0;
