From: Christina Jacob <christina.jacob.koikara@gmail.com>
Subject: [PATCH v3 0/1] XDP program for ip forward
Date: Wed,  1 Nov 2017 13:18:03 +0530
Message-ID: <1509522484-30215-1-git-send-email-christina.jacob.koikara@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        brouer@redhat.com, Sunil.Goutham@cavium.com,
        Christina.Jacob@cavium.com, stephen@networkplumber.org,
        ddaney@caviumnetworks.com, David.Laight@aculab.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch below implements port to port forwarding through route table and arp
table lookup for ipv4 packets using bpf_redirect helper function and lpm_trie
map.  This has an improved performance over the normal kernel stack ip forward.

Implementation details.
-----------------------
The program uses one map each for arp table, route table and packet count.
The number of entries the program can process is limited by the size of the
map used.

In the xdp_router_ipv4_user.c,

initially, the routing table is read and is stored in an lpm trie map.
The arp table is read and stored in an array map There are two netlink sockets
that listens to any change in the route table  and arp table.
There are two types of changes to the route table.
        1.New

        The new entries are added to the lpm_trie with proper key and prefix
        length If there is a another entry in the route table with a different
        metric(only metric is considered). Then the values are compared and the
        one with lowest metric is added to the node.

        2.Deletion

        On deletion from the route table, The particular node is removed and the
        entire route table is again read to check if there is another entry with
        a different metric.

This implementation depends on  bpf: Implement map_delete_elem for
BPF_MAP_TYPE_LPM_TRIE which is not yet upstreamed.

There are two types of changes to the route table

        1.New

        The new arp entries are added in the in the array map directly with the
        ip address as the key and the destination mac address as the value.

        2.Delete

        The entry corresponding to the particular ip is deleted from the
        arp table map.

Another map is maintained for entries in the route table having 32 bit mask.
such entries can have a corresponding  arp entry which if  stored together with
the route entry in an array map and can be accessed in O(1) time. Eliminating
the trie lookup and arp lookup.

In the xdp_router_ipv4_kern.c,

The array map for the 32 bit mask entries checked to see if there is a key that
exactly matches with the destination ip. If it has a non zero destination mac
entry then the xdp data is updated accordingly Otherwise a proper route and
arp table lookup is done using the lpm_trie and the arp table array map.

        Usage: as ./xdp_router_ipv4 -S <ifindex1...ifindexn> (-S for
        generic xdp implementation ifindex- the index of the interface to which
        the xdp program has to be attached.) in 4.14-rc3 kernel.

Changes from v1 to v2
---------------------

* As suggested by Jesper Dangaard Brouer
        1. Changed the program name to  list xdp_router_ipv4
        2. Changed the commandline arguments from ifindex list to interface name
                Usage : ./xdp_router_ipv4 [-S] <interface name list>
                -S for generic xdp implementation
                -interface name list is the list of interfaces to which
                the xdp program should attach to

* As suggested by Daniel Borkmann
        1. Using __builin_memcpy to update source and destination mac in the bpf
          kernel program.

        2. Started using __be32 in the kernel program to be inline with the data
           type used in user program

        3. Rectified few style issues.

* Corrected the copyright issue pointed out by David Ahern

* Fixed the bug: The already attached interfaces are not detached from the
  xdp program if the program fails to attach to an interface later in the list.


Changes from v2 to v3
---------------------
* As pointed out by Jesper Dangaard Brouer
               1. Changed the program name in the cover letter.
	       2. Changed variable declararions to follow Reverse-xmas tree
	          rule.
	       3. Reduced the nesting in code for readability.
	       4. Fixed bug: incorrect mac address being set for source and
	          destination mac.
	       5. Fixed comment style.

* As suggested by Stephen Hemminger 
		Changed all the bzeros' to memset.

* As suggested by David Laight
		removed the signed remainders calculation.

* As suggested by Stephen Hemminger and David Daney 
		1. Added checks for the ioctl return value.
		2. Changed data types to be64 to be sure about the size of the
		   data type.
		3. Verified byte order. Using the mac address from ioctl in
		   network byte order. not casting to to long data type
		   anymore.
		4. Fixed returning address of local variable.


Christina Jacob (1):
  xdp: Sample xdp program implementing ip forward

 samples/bpf/Makefile               |   4 +
 samples/bpf/xdp_router_ipv4_kern.c | 181 ++++++++++
 samples/bpf/xdp_router_ipv4_user.c | 657 +++++++++++++++++++++++++++++++++++++
 3 files changed, 842 insertions(+)
 create mode 100644 samples/bpf/xdp_router_ipv4_kern.c
 create mode 100644 samples/bpf/xdp_router_ipv4_user.c

-- 
2.7.4
