From: cjacob <Christina.Jacob@cavium.com>
Subject: [PATCH 0/1] XDP Program for Ip forward
Date: Tue,  3 Oct 2017 13:07:04 +0530
Message-ID: <1507016225-319-1-git-send-email-Christina.Jacob@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Christina.Jacob@cavium.com, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
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

initially, the routing table is read and stored in an lpm trie map.
The arp table is read and stored in an array map. There are two netlink sockets
that listen to any change in the route table and arp table.
There are two types of changes to the route table.

	1.New
	
	The new entries are added to the lpm trie with proper key and prefix
	length. If there is a another entry in the route table with a different
	metric(only metric is considered), then the values are compared and the
	one with lowest metric is added to the trie node.
	
	2.Deletion 

	On deletion from the route table, the particular node is removed and the
	entire route table is read again to check if there is another entry with
	the same key and prefix length but a different metric. If it exists it
	is added to the lpm trie.

This implementation depends on Patch bpf: Implement map_delete_elem for
BPF_MAP_TYPE_LPM_TRIE which is not yet upstreamed.

There are two types of changes to the route table

	1.New
	
	The new arp entries are added in the in the array map directly with the
	ip address as the key and the destination mac address as the value.
	
	2.Delete 
	
	The entry corresponding to the particular ip is deleted from the 
	arp table map.

Another map is maintained for entries in the route table having 32 bit mask.
Such entries can have a corresponding arp entry which if stored together with
the route entry in an array map and can be accessed in O(1) time, thereby 
eliminating the trie lookup and arp lookup.

In the xdp3_kern.c,

The array map for the 32 bit mask entries is checked to see if there is a key
that exactly matches the destination ip. If it has a non zero destination mac
entry then the xdp data is updated accordingly. Otherwise a proper route and 
arp table lookup is done using the lpm_trie and the arp table array map.
	
	Usage: ./xdp3 [-S] <ifindex1...ifindexn> 

	-S to choose generic xdp implementation 
	  [Default is driver xdp implementation]
	ifindex - the index of the interface to which 
	the xdp program has to be attached.
	in 4.14-rc3 kernel.


cjacob (1):
  xdp: Sample xdp program implementing ip forward

 samples/bpf/Makefile    |    4 +
 samples/bpf/xdp3_kern.c |  204 +++++++++++++++
 samples/bpf/xdp3_user.c |  649 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 857 insertions(+), 0 deletions(-)
 create mode 100644 samples/bpf/xdp3_kern.c
 create mode 100644 samples/bpf/xdp3_user.c
