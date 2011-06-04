From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC] breakage in sysfs_readdir() and s_instances abuse in sysfs
Date: Sat, 4 Jun 2011 23:23:45 +0100
Message-ID: <20110604222345.GZ11521@ZenIV.linux.org.uk>
References: <20110604001518.GT11521@ZenIV.linux.org.uk>
 <20110604212259.GY11521@ZenIV.linux.org.uk>
 <BANLkTikChZuG4pOZ_ipDYaEv8VQ8omh-YQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@aristanetworks.com>,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <BANLkTikChZuG4pOZ_ipDYaEv8VQ8omh-YQ@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 05, 2011 at 06:55:12AM +0900, Linus Torvalds wrote:
> On Sun, Jun 5, 2011 at 6:22 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> >
> > Are you OK with the sketch above? ?I can probably cook a patch along those
> > lines by tomorrow...
> 
> I'm ok with the sketch, but might think otherwise when actually seeing
> the patch. And I wish some namespace person would look at this issue.
> And the networking people would seem to need to be aware of it too,
> but you've only cc'd fsdevel, so they are entirely unaware of the
> whole thread..

Eh...  The question had been to Eric, unless that pile is actually yours...
netdev Cc'd, and I'll forward the previous posting there in a few.

FWIW, reproducing that is trivial: on a box with netns enabled:

dizzy:~# unshare -n -- sh -c "mount -t sysfs none /mnt; ls -l /mnt/class/net; ls
 -l /mnt/class/net/eth0"                                                        
[ 1301.429755] IPv4 FIB: Using LC-trie version 0.409                            
total 0                                                                         
lrwxrwxrwx 1 root root 0 Jun  4 18:16 lo -> ../../devices/virtual/net/lo        
lrwxrwxrwx 1 root root 0 Jun  4 18:16 sit0 -> ../../devices/virtual/net/sit0    
ls: cannot access /mnt/class/net/eth0: No such file or directory                
dizzy:~# ls -l /mnt/class/net/; ls -l /mnt/class/net/eth0                       
total 0                                                                         
lrwxrwxrwx 1 root root 0 Jun  4 18:17 /mnt/class/net/eth0 -> ../../devices/pci00
00:00/0000:00:09.0/net/eth0                                                     

IOW, while netns is alive we get sane behaviour - lookup for class/net/eth0
fails, since there's no such object in that netns.  Once it's gone, we get
class/net in that sysfs instance empty on readdir *and* lookup for
class/net/eth0 succeeds giving us an object from another netns.

Apologies for not adding netdev - it started as sysfs-internal race, so the
beginning of that thread went to fsdevel...
