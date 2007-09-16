From: Kyle Moffett <mrmacman_g4@mac.com>
Subject: Re: Distributed storage. Move away from char device ioctls.
Date: Sun, 16 Sep 2007 03:07:11 -0400
Message-ID: <AC64AEB4-4090-4E73-A53C-2ACF94B49AD5@mac.com>
References: <20070914185429.GA9439@2ka.mipt.ru> <46EADC02.9070409@garzik.org> <20070915122957.GA25752@2ka.mipt.ru> <20070915172446.GC2990@schatzie.adilger.int>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Andreas Dilger <adilger@clusterfs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpoutm.mac.com ([17.148.16.72]:63270 "EHLO smtpoutm.mac.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751205AbXIPHH3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Sep 2007 03:07:29 -0400
In-Reply-To: <20070915172446.GC2990@schatzie.adilger.int>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sep 15, 2007, at 13:24:46, Andreas Dilger wrote:
> On Sep 15, 2007  16:29 +0400, Evgeniy Polyakov wrote:
>> Yes, block device itself is not able to scale well, but it is the  
>> place for redundancy, since filesystem will just fail if  
>> underlying device does not work correctly and FS actually does not  
>> know about where it should place redundancy bits - it might happen  
>> to be the same broken disk, so I created a low-level device which  
>> distribute requests itself.
>
> I actually think there is a place for this - and improvements are  
> definitely welcome.  Even Lustre needs block-device level  
> redundancy currently, though we will be working to make Lustre- 
> level redundancy available in the future (the problem is WAY harder  
> than it seems at first glance, if you allow writeback caches at the  
> clients and servers).

I really think that to get proper non-block-device-level filesystem  
redundancy you need to base it on something similar to the GIT  
model.  Data replication is done in specific-sized chunks indexed by  
SHA-1 sum and you actually have a sort of "merge algorithm" for when  
local and remote changes differ.  The OS would only implement a very  
limited list of merge algorithms, IE one of:

(A)  Don't merge, each client gets its own branch and merges are manual
(B)  Most recent changed version is made the master every X-seconds/ 
open/close/write/other-event.
(C)  The tree at X (usually a particular client/server) is always  
used as the master when there are conflicts.

This lets you implement whatever replication policy you want:  You  
can require that some files are replicated (cached) on *EVERY*  
system, you can require that other files are cached on at least X  
systems.  You can say "this needs to be replicated on at least X% of  
the online systems, or at most Y".  Moreover, the replication could  
be done pretty easily from userspace via a couple syscalls.  You also  
automatically keep track of history with some default purge policy.

The main point is that for efficiency and speed things are *not*  
always replicated; this also allows for offline operation.  You would  
of course have "userspace" merge drivers which notice that the tree  
on your laptop is not a subset/superset of the tree on your desktop  
and do various merges based on per-file metadata.  My address-book,  
for example, would have a custom little merge program which knows  
about how to merge changes between two address book files, asking me  
useful questions along the way.  Since a lot of this merging is  
mechanical, some of the code from GIT could easily be made into a  
"merge library" which knows how to do such things.

Moreover, this would allow me to have a "shared" root filesystem on  
my laptop and desktop.  It would have 'sub-project'-type trees, so  
that "/" would be an independent branch on each system. "/etc" would  
be separate branches but manually merged git-style as I make  
changes.  "/home/*" folders would be auto-created as separate  
subtrees so each user can version their own individually.  Specific  
subfolders (like address-book, email, etc) would be adjusted by the  
GUI programs that manage them to be separate subtrees with manual- 
merging controlled by that GUI program.

Backups/dumps/archival of such a system would be easy.  You would  
just need to clone the significant commits/trees/etc to a DVD and  
replace the old SHA-1-indexed objects to tiny "object-deleted" stubs;  
to rollback to an archived version you insert the DVD, "mount" it  
into the existing kernel SHA-1 index, and then mount the appropriate  
commit as a read-only volume somewhere to access.  The same procedure  
would also work for wide-area-network backups and such.

The effective result would be the ability to do things like the  
following:
   (A)  Have my homedir synced between both systems mostly- 
automatically as I make changes to different files on both systems
   (B)  Easily have 2 copies of all my files, so if one system's disk  
goes kaput I can just re-clone from the other.
   (C)  Keep archived copies of the last 5 years worth of work,  
including change history, on a stack of DVDs.
   (D)  Synchronize work between locations over a relatively slow  
link without much work.

As long as files were indirectly indexed by sub-block SHA1 (with the  
index depth based on the size of the file), and each individually- 
SHA1-ed object could have references, you could trivially have a 4TB- 
sized file where you modify 4 bytes at a thousand random locations  
throughout the file and only have to update about 5MB worth of on- 
disk data.  The actual overhead for that kind of operation under any  
existing filesystem would be 100% seek-dominated regardless whereas  
with this mechanism you would not directly be overwriting data and so  
you could append all the updates as a single 5MB chunk.  Data reads  
would be much more seek-y, but you could trivially have an on-line  
defragmenter tool which notices fragmented commonly-accessed inode  
objects and creates non-fragmented copies before deleting the old ones.

There's a lot of other technical details which would need resolution  
in an actual implementation, but this is enough of a summary to give  
you the gist of the concept.  Most likely there will be some major  
flaw which makes it impossible to produce reliably, but the concept  
contains the things I would be interested in for a real "networked  
filesystem".

Cheers,
Kyle Moffett
