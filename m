From: Chris J Arges <chris.j.arges@canonical.com>
Subject: [PATCH] Re: iproute2: potential upgrade regression with 58a3e827
Date: Fri, 13 Dec 2013 12:46:09 -0600
Message-ID: <52AB55F1.8000301@canonical.com>
References: <527D2768.1030403@canonical.com> <527E6A32.5020808@hp.com>	 <52814B88.1050708@canonical.com> <1384205890.2758.28.camel@dilip-laptop>	 <871u2mblzk.fsf@xmission.com> <1384216612.2758.30.camel@dilip-laptop>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010203080301040009050908"
Cc: Brian Haley <brian.haley@hp.com>, shemminger@osdl.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: dilip.daya@hp.com, "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:36682 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752644Ab3LMSqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 13:46:22 -0500
In-Reply-To: <1384216612.2758.30.camel@dilip-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010203080301040009050908
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

On 11/11/2013 06:36 PM, Dilip Daya wrote:
> Hi Eric,
> 
> On Mon, 2013-11-11 at 14:40 -0800, Eric W. Biederman wrote:
>> Dilip Daya <dilip.daya@hp.com> writes:
>>
>>> Hi Chris,
>>>
>>> On Mon, 2013-11-11 at 15:26 -0600, Chris J Arges wrote:
>>>
>>>> Good suggestion,
>>>> So I'll use a more simple example now:
>>>>
>>>> 1)
>>>> ip netns add first
>>>> ip netns exec first bash
>>>>
>>>> 2)
>>>> ip netns add second
>>>> ip netns exec second bash
>>>>
>>>> 3)
>>>> ip netns exec first bash
>>>>
>>>> If we do not upgrade the package, after we execute (2) we have:
>>>> # ls -l /var/run/netns
>>>> total 0
>>>> -r-------- 1 root root 0 Nov 11 20:38 first
>>>> -r-------- 1 root root 0 Nov 11 20:38 second
>>>>
>>>> If we upgrade after (1), then run (2) we have:
>>>> # ls -l /var/run/netns
>>>> total 0
>>>> ---------- 1 root root 0 Nov 11 20:56 first
>>>> -r-------- 1 root root 0 Nov 11 20:57 second
>>>>
>>>> So looks like netns add is doing something different from 58a3e827 and on.
>>
>> I will just add that it is worth looking at /proc/mounts as well.
>>
>> Although I have to admit that the difference in permissions is odd.
> 
> 
> => kernel v3.2.51 with iproute2-ss130903
> 
> 
> Terminal #1--Add first netns
> # ip netns add first
> 
> 
> Terminal #1:
> # tree --inodes /var/run/netns ; echo "=====" ; ls -li /var/run/netns ; echo "====="; cat /proc/self/mounts | grep first ; echo "=====" ; cat /proc/self/mountinfo | grep -e first
> /var/run/netns
> └── [   5204]  first
> 
> 0 directories, 1 file
> =====
> total 0
> 5204 -r-------- 1 root root 0 Nov 11 17:17 first
> =====
> none /var/run/netns/first proc rw,nosuid,nodev,noexec,relatime 0 0
> =====
> 23 22 0:3 /1935/ns/net /var/run/netns/first rw,nosuid,nodev,noexec,relatime shared:2 - proc none rw
> 
> 
> Terminal #1:
> # ip netns exec first /bin/bash
> 
> 
> Terminal #1:
> # tree --inodes /var/run/netns ; echo "=====" ; ls -li /var/run/netns ; echo "====="; cat /proc/self/mounts | grep first ; echo "=====" ; cat /proc/self/mountinfo | grep -e first
> /var/run/netns
> └── [   5204]  first
> 
> 0 directories, 1 file
> =====
> total 0
> 5204 -r-------- 1 root root 0 Nov 11 17:17 first
> =====
> none /var/run/netns/first proc rw,nosuid,nodev,noexec,relatime 0 0
> first /sys sysfs rw,relatime 0 0
> =====
> 33 32 0:3 /1935/ns/net /var/run/netns/first rw,nosuid,nodev,noexec,relatime master:2 - proc none rw
> 29 25 0:17 / /sys rw,relatime - sysfs first rw
> 
> 
> Terminal #1:
> # ip netns add second
> 
> 
> Terminal #1:
> # tree --inodes /var/run/netns ; echo "=====" ; ls -li /var/run/netns ; echo "====="; cat /proc/self/mounts | grep first ; echo "=====" ; cat /proc/self/mountinfo | grep -e first -e second
> /var/run/netns
> ├── [   5204]  first
> └── [   5236]  second
> 
> 0 directories, 2 files
> =====
> total 0
> 5204 -r-------- 1 root root 0 Nov 11 17:17 first
> 5236 -r-------- 1 root root 0 Nov 11 17:21 second   <<< observe this inode # and permissions
> =====
> none /var/run/netns/first proc rw,nosuid,nodev,noexec,relatime 0 0
> first /sys sysfs rw,relatime 0 0
> =====
> 33 32 0:3 /1935/ns/net /var/run/netns/first rw,nosuid,nodev,noexec,relatime shared:4 master:2 - proc none rw
> 29 25 0:17 / /sys rw,relatime - sysfs first rw
> 34 32 0:3 /1955/ns/net /var/run/netns/second rw,nosuid,nodev,noexec,relatime shared:5 - proc none rw
> 
> 
> 
> Terminal #2--in main (not in netns):
> # tree --inodes /var/run/netns ; echo "=====" ; ls -li /var/run/netns ; echo "====="; cat /proc/self/mounts | grep first ; echo "=====" ; cat /proc/self/mountinfo | grep -e first -e second
> /var/run/netns
> ├── [   5204]  first
> └── [  51492]  second   <<< inode is different
> 
> 0 directories, 2 files
> =====
> total 0
>  5204 -r-------- 1 root root 0 Nov 11 17:17 first
> 51492 ---------- 1 root root 0 Nov 11 17:21 second   << inode different with NULL permissions
> =====
> none /var/run/netns/first proc rw,nosuid,nodev,noexec,relatime 0 0
> =====
> 23 22 0:3 /1935/ns/net /var/run/netns/first rw,nosuid,nodev,noexec,relatime shared:2 - proc none rw
> 
> => When in main (not in netns) "second" netns is not viewable.
> 
> 
> Terminal #2--Enter first:
> # ip netns exec first bash
> 
> 
> Terminal #2:
> # tree --inodes /var/run/netns ; echo "=====" ; ls -li /var/run/netns ; echo "====="; cat /proc/self/mounts | grep first ; echo "=====" ; cat /proc/self/mountinfo | grep -e first -e second
> /var/run/netns
> ├── [   5204]  first
> └── [  51492]  second   <<< inode different then when created from first in Terminal #1 above
> 
> 0 directories, 2 files
> =====
> total 0
>  5204 -r-------- 1 root root 0 Nov 11 17:17 first
> 51492 ---------- 1 root root 0 Nov 11 17:21 second   <<< inode with NULL permissions
> =====
> none /var/run/netns/first proc rw,nosuid,nodev,noexec,relatime 0 0
> first /sys sysfs rw,relatime 0 0
> =====
> 44 43 0:3 /1935/ns/net /var/run/netns/first rw,nosuid,nodev,noexec,relatime master:2 - proc none rw
> 40 36 0:17 / /sys rw,relatime - sysfs first rw
> 
> => mounts and mountinfo does not show "second"
> 
> 
> Terminal #2:
> # ip netns exec second /bin/bash
> seting the network namespace "second" failed: Invalid argument
> 
> => "second" netns is now rendered unusable from "first" netns and from main.
> 
> 
> 
> Thanks,
> -DilipD.
> 
> 
> 
>>
>> Eric
> 

Attached is a patch that solves this issue for me. I traced through the
error values of mount and noticed the errno was being set to EINVAL (as
we'd expect per man 2 mount). However, this seemed to be causing issues
with later mount commands. I've reset the errno before the next mount
command in that loop.

Please review this patch,
Thanks,
--chris j arges




--------------010203080301040009050908
Content-Type: text/x-patch;
 name="0001-Fix-for-upgrade-regression-in-58a3e827.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-Fix-for-upgrade-regression-in-58a3e827.patch"

>From 88494a34106df25827cb46820f6272915bee6e85 Mon Sep 17 00:00:00 2001
From: Chris J Arges <chris.j.arges@canonical.com>
Date: Fri, 13 Dec 2013 12:29:12 -0600
Subject: [PATCH] Fix for upgrade regression in 58a3e827

Commit 58a3e8270fe72f8ed92687d3a3132c2a708582dd introduces a regression
when upgrading code with existing active network namespaces.

Test case:
ip netns add first
ip netns exec first bash
  < upgrade to 58a3e827 version >
ip netns add second
ip netns exec second bash
ip netns exec first bash

This will work if you are using only versions before this commit, or
only versions after the commit. Otherwise you will get the following message:

seting the network namespace failed: Invalid argument

This also fixes the spelling error in that message.

Signed-off-by: Chris J Arges <chris.j.arges@canonical.com>
---
 ip/ipnetns.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 89dda3f..c5d7bde 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -158,7 +158,7 @@ static int netns_exec(int argc, char **argv)
 	}
 
 	if (setns(netns, CLONE_NEWNET) < 0) {
-		fprintf(stderr, "seting the network namespace \"%s\" failed: %s\n",
+		fprintf(stderr, "setting the network namespace \"%s\" failed: %s\n",
 			name, strerror(errno));
 		return -1;
 	}
@@ -424,6 +424,7 @@ static int netns_add(int argc, char **argv)
 		}
 
 		/* Upgrade NETNS_RUN_DIR to a mount point */
+		errno = 0;
 		if (mount(NETNS_RUN_DIR, NETNS_RUN_DIR, "none", MS_BIND, NULL)) {
 			fprintf(stderr, "mount --bind %s %s failed: %s\n",
 				NETNS_RUN_DIR, NETNS_RUN_DIR, strerror(errno));
-- 
1.7.9.5


--------------010203080301040009050908--
