From: "David S. Miller" <davem@redhat.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Fri, 06 Sep 2002 12:21:18 -0700 (PDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20020906.122118.52140394.davem@redhat.com>
References: <3D78E7A5.7050306@us.ibm.com>
	<20020906202646.A2185@wotan.suse.de>
	<1031339954.3d78ffb257d22@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: niv@us.ibm.com
In-Reply-To: <1031339954.3d78ffb257d22@imap.linux.ibm.com>
List-Id: netdev.vger.kernel.org

   From: Nivedita Singhvi <niv@us.ibm.com>
   Date: Fri,  6 Sep 2002 12:19:14 -0700
   
   inet_bind() and tcp_v4_get_port() are up there because
   we have to grab the socket lock, the tcp_portalloc_lock,
   then the head chain lock and traverse the hash table
   which has now many hundred entries. Also, because
   of the varied length of the connections, the clients
   get freed not in the same order they are allocated
   a port, hence the fragmentation of the port space..
   Tthere is some cacheline thrashing hurting the NUMA 
   more than other systems here too..
   
There are methods to eliminate the centrality of the
port allocation locking.

Basically, kill tcp_portalloc_lock and make the port rover be per-cpu.

The only tricky case is the "out of ports" situation.  Because there
is no centralized locking being used to serialize port allocation,
it is difficult to be sure that the port space is truly exhausted.

Another idea, which doesn't eliminate the tcp_portalloc_lock but
has other good SMP properties, is to apply a "cpu salt" to the
port rover value.  For example, shift the local cpu number into
the upper parts of a 'u16', then 'xor' that with tcp_port_rover.

Alexey and I have discussed this several times but never became
bored enough to experiment :-)
