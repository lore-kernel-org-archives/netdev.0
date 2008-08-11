From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v2 0/7] Labeled networking patches for 2.6.28
Date: Mon, 11 Aug 2008 18:23:49 -0400
Message-ID: <20080811212640.22551.17728.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

An updated patchset that includes some RCU/locking fixes from Paul McKenney,
a tweak to the SELinux socket security structure to cache the NetLabel
security attribute structure (last patch, not present in previous version),
as well as some small other fixes I found over the weekend.  The patches
are still pretty rough around the edges but they are getting there, once 
again, any comments or feedback you have are greatly appreciated.

I've updated the git tree, no changes have been made to the userspace tools
since last posting.

 * git://git.infradead.org/users/pcmoore/lblnet-2.6_testing
 * http://netlabel.svn.sf.net/viewvc/netlabel/netlabel_tools/branches/addrsel

As promised, I'm also including some instructions on how to configure the
new functionality as well.  The first step is to download and build the
"addrsel" branch of the netlabel_tools package, you can do that with the
following commands:

 # svn co https://netlabel.svn.sourceforge.net/svnroot/netlabel netlabel
 # cd netlabel/netlabel_tools/branches/addrsel
 # make

Then you need to use the netlabelctl tool you just built to configure the
NetLabel subsystem.  The following commands create a CIPSO DOI and use it to
label traffic sent to 127.0.0.1 by ping, aka the ping_t domain, all other
ping traffic is unlabeled.  Remember you _must_ have a catch-all address,
i.e. 0.0.0.0/0, configured for each domain that you configure to use the new
address selectors; failure to do so will cause unmatched traffic to be
dropped, similar to what would happen if you didn't have a domain mapping
configured under the original configuration scheme.  In general, think of the
catch-all addresses, 0.0.0.0/0 and ::/0, as the "DEFAULT" domain mapping.

[NOTE: in the process of writing the examples below I found a bug in the
       'netlabelctl cipsov4 del ...' operation, I'm looking into it right now
       but in the meantime only add :) ]

 # ./netlabelctl cipsov4 add pass doi:1 tags:1,2,5
 # ./netlabelctl -p cipsov4 list doi:1
 Configured CIPSOv4 mapping (DOI = 1)
  tags (3):
    RESTRICTED BITMAP
    ENUMERATED
    RANGED
 # ./netlabelctl -p map list
 Configured NetLabel domain mappings (1)
  domain: DEFAULT
    protocol: UNLABELED
 # ./netlabelctl map add domain:ping_t protocol:unlbl address:0.0.0.0/0
 # ./netlabelctl map add domain:ping_t protocol:cipsov4,1 address:127.0.0.1
 # ./netlabelctl -p map list
 Configured NetLabel domain mappings (2)
  domain: "ping_t"
    address: 127.0.0.1/32
     protocol: CIPSOv4, DOI = 1
    address: 0.0.0.0/0
     protocol: UNLABELED
  domain: DEFAULT
    protocol: UNLABELED

We can test this by pinging the host's address where we don't see any
additional IP options, in other words an unlabeled packet ...

 # ping -c 1 bob.lan
 PING bob.lan (192.168.0.169) 56(84) bytes of data.
 64 bytes from bob.lan (192.168.0.169): icmp_seq=1 ttl=64 time=0.061 ms

 --- bob.lan ping statistics ---
 1 packets transmitted, 1 received, 0% packet loss, time 0ms
 rtt min/avg/max/mdev = 0.061/0.061/0.061/0.000 ms

... however, if we ping localhost we can see the telltale "unknown option 86"
that tells us a CIPSO option is present on the packet.

 # ping -c 1 localhost
 PING localhost.localdomain (127.0.0.1) 56(84) bytes of data.
 64 bytes from localhost.localdomain (127.0.0.1): icmp_seq=1 ttl=64 time=0.056 ms
 unknown option 86

 --- localhost.localdomain ping statistics ---
 1 packets transmitted, 1 received, 0% packet loss, time 0ms
 rtt min/avg/max/mdev = 0.056/0.056/0.056/0.000 ms

Tada!

-- 
paul moore
linux @ hp
