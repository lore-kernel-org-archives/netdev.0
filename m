From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [RFC PATCH 00/17] fib_trie: Reduce time spent in fib_table_lookup
 by 35 to 75%
Date: Mon, 22 Dec 2014 10:38:12 -0800
Message-ID: <54986514.1010502@redhat.com>
References: <20141222172632.1119.51469.stgit@ahduyck-vm-fedora20> <CAA93jw7Zz8_wToKOou42mXhgunZypQ6f=oGEHZk2K6CbrsrNqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33487 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754354AbaLVSiP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Dec 2014 13:38:15 -0500
In-Reply-To: <CAA93jw7Zz8_wToKOou42mXhgunZypQ6f=oGEHZk2K6CbrsrNqg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/22/2014 10:08 AM, Dave Taht wrote:
> impressive. I think. But I don't quite understand what you mean by a depth of 7?
>
> What did your routing table actually look like?
>
> For example, my ipv4 routing table looks like this at the moment.
>
> What is depth? searching from /32, /31, /30, /29?

What I was referring to is the local trie since all routing ends up 
having to do a failed lookup there before we can look in the main trie.

What I did is populate a list of addresses such that I had 15 bits set 
in the lower 16 of the address.  By doing that it allowed me to stress 
the trie pretty hard since it can only inflate out to a tnode with 8 
children.

My routing test was from my ixgbe which was on a 10.0.0.X address to a 
dummy address at 192.168.255.253 which resulted in it being routed to 
the dummy interface.  The ixgbe to local receive was to address 
192.168.255.254.

Below is all the info for my trie.

- Alex

[root@ahduyck-vm-fedora20 net]# cat /proc/net/fib_triestat
Basic info: size of leaf: 40 bytes, size of tnode: 40 bytes.
Main:
     Aver depth:     2.80
     Max depth:      4
     Leaves:         15
     Prefixes:       15
     Internal nodes: 6
       2: 2  3: 4
     Pointers: 40
Null ptrs: 20
Total size: 2  kB

Local:
     Aver depth:     3.87
     Max depth:      7
     Leaves:         49
     Prefixes:       50
     Internal nodes: 24
       1: 10  2: 6  3: 7  4: 1
     Pointers: 116
Null ptrs: 44
Total size: 7  kB

[root@ahduyck-vm-fedora20 ~]# cat /proc/net/fib_trie
Main:
   +-- 0.0.0.0/0 3 0 5
      +-- 0.0.0.0/4 2 0 2
         |-- 0.0.0.0
            /0 universe UNICAST
         +-- 10.0.0.0/22 3 0 4
            |-- 10.0.0.0
               /24 link UNICAST
            |-- 10.0.1.0
               /24 link UNICAST
            |-- 10.0.2.0
               /24 link UNICAST
            |-- 10.0.3.0
               /24 link UNICAST
      |-- 169.254.0.0
         /16 link UNICAST
      +-- 192.168.0.0/16 3 1 4
         |-- 192.168.122.0
            /24 link UNICAST
         |-- 192.168.128.0
            /24 link UNICAST
         |-- 192.168.192.0
            /24 link UNICAST
         +-- 192.168.224.0/19 3 1 4
            |-- 192.168.224.0
               /24 link UNICAST
            |-- 192.168.240.0
               /24 link UNICAST
            |-- 192.168.248.0
               /24 link UNICAST
            +-- 192.168.252.0/22 2 0 1
               |-- 192.168.252.0
                  /24 link UNICAST
               |-- 192.168.254.0
                  /24 link UNICAST
               |-- 192.168.255.0
                  /24 link UNICAST
Local:
   +-- 0.0.0.0/0 3 0 5
      +-- 10.0.0.0/22 4 0 4
         |-- 10.0.0.0
            /32 link BROADCAST
         |-- 10.0.0.128
            /32 host LOCAL
         |-- 10.0.0.255
            /32 link BROADCAST
         |-- 10.0.1.0
            /32 link BROADCAST
         |-- 10.0.1.128
            /32 host LOCAL
         |-- 10.0.1.255
            /32 link BROADCAST
         |-- 10.0.2.0
            /32 link BROADCAST
         |-- 10.0.2.128
            /32 host LOCAL
         |-- 10.0.2.255
            /32 link BROADCAST
         |-- 10.0.3.0
            /32 link BROADCAST
         |-- 10.0.3.128
            /32 host LOCAL
         |-- 10.0.3.255
            /32 link BROADCAST
      +-- 127.0.0.0/8 2 0 2
         +-- 127.0.0.0/31 1 0 0
            |-- 127.0.0.0
               /32 link BROADCAST
               /8 host LOCAL
            |-- 127.0.0.1
               /32 host LOCAL
         |-- 127.255.255.255
            /32 link BROADCAST
      +-- 192.168.0.0/16 3 1 4
         +-- 192.168.122.0/24 2 0 1
            |-- 192.168.122.0
               /32 link BROADCAST
            |-- 192.168.122.173
               /32 host LOCAL
            |-- 192.168.122.255
               /32 link BROADCAST
         +-- 192.168.128.0/24 2 0 2
            +-- 192.168.128.0/31 1 0 0
               |-- 192.168.128.0
                  /32 link BROADCAST
               |-- 192.168.128.1
                  /32 host LOCAL
            |-- 192.168.128.255
               /32 link BROADCAST
         +-- 192.168.192.0/24 2 0 2
            +-- 192.168.192.0/31 1 0 0
               |-- 192.168.192.0
                  /32 link BROADCAST
               |-- 192.168.192.1
                  /32 host LOCAL
            |-- 192.168.192.255
               /32 link BROADCAST
         +-- 192.168.224.0/19 3 2 4
            +-- 192.168.224.0/24 2 0 2
                  |-- 192.168.224.0
                     /32 link BROADCAST
                  |-- 192.168.224.1
                     /32 host LOCAL
               |-- 192.168.224.255
                  /32 link BROADCAST
            +-- 192.168.240.0/24 2 0 2
               +-- 192.168.240.0/31 1 0 0
                  |-- 192.168.240.0
                     /32 link BROADCAST
                  |-- 192.168.240.1
                     /32 host LOCAL
               |-- 192.168.240.255
                  /32 link BROADCAST
            +-- 192.168.248.0/22 3 0 6
               +-- 192.168.248.0/31 1 0 0
                  |-- 192.168.248.0
                     /32 link BROADCAST
                  |-- 192.168.248.1
                     /32 host LOCAL
               |-- 192.168.248.255
                  /32 link BROADCAST
            +-- 192.168.252.0/22 3 1 2
               +-- 192.168.252.0/31 1 0 0
                  |-- 192.168.252.0
                     /32 link BROADCAST
                  |-- 192.168.252.1
                     /32 host LOCAL
               |-- 192.168.252.255
                  /32 link BROADCAST
               +-- 192.168.254.0/31 1 0 0
                  |-- 192.168.254.0
                     /32 link BROADCAST
                  |-- 192.168.254.1
                     /32 host LOCAL
               |-- 192.168.254.255
                  /32 link BROADCAST
               +-- 192.168.255.0/31 1 0 0
                  |-- 192.168.255.0
                     /32 link BROADCAST
                  |-- 192.168.255.1
                     /32 host LOCAL
               +-- 192.168.255.128/25 3 1 4
                  |-- 192.168.255.128
                     /32 host LOCAL
                  |-- 192.168.255.192
                     /32 host LOCAL
                  |-- 192.168.255.224
                     /32 host LOCAL
                  +-- 192.168.255.240/28 3 1 4
                     |-- 192.168.255.240
                        /32 host LOCAL
                     |-- 192.168.255.248
                        /32 host LOCAL
                     |-- 192.168.255.252
                        /32 host LOCAL
                     +-- 192.168.255.254/31 1 0 0
                        |-- 192.168.255.254
                           /32 host LOCAL
                        |-- 192.168.255.255
                           /32 link BROADCAST
