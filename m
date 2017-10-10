From: Christina Jacob <christina.jacob.koikara@gmail.com>
Subject: [PATCH v2] XDP Program for Ip forward
Date: Tue, 10 Oct 2017 12:58:51 +0530
Message-ID: <1507620532-25804-1-git-send-email-Christina.Jacob@cavium.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        brouer@redhat.com, Sunil.Goutham@cavium.com, daniel@iogearbox.net,
        dsahern@gmail.com, Christina Jacob <Christina.Jacob@cavium.com>
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

In the xdp3_user.c,

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

In the xdp3_kern.c,

The array map for the 32 bit mask entries checked to see if there is a key that
exactly matches with the destination ip. If it has a non zero destination mac
entry then the xdp data is updated accordingly Otherwise a proper route and 
arp table lookup is done using the lpm_trie and the arp table array map.
	
	Usage: as ./xdp3 -S <ifindex1...ifindexn> (-S for
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


Christina Jacob (1):
  xdp: Sample xdp program implementing ip forward

 samples/bpf/Makefile               |    4 +
 samples/bpf/xdp_router_ipv4_kern.c |  189 +++++++++++
 samples/bpf/xdp_router_ipv4_user.c |  655 ++++++++++++++++++++++++++++++++++++
 3 files changed, 848 insertions(+), 0 deletions(-)
 create mode 100644 samples/bpf/xdp_router_ipv4_kern.c
 create mode 100644 samples/bpf/xdp_router_ipv4_user.c
