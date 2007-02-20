From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 12:09:51 +0100
Message-ID: <200702201209.52388.dada1@cosmosbay.com>
References: <20070204074143.26312.qmail@science.horizon.com> <200702201104.16200.dada1@cosmosbay.com> <20070220104418.GA5262@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: akepner@sgi.com, linux@horizon.com, davem@davemloft.net,
	netdev@vger.kernel.org, bcrl@kvack.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:39334 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932874AbXBTLKc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 06:10:32 -0500
In-Reply-To: <20070220104418.GA5262@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 20 February 2007 11:44, Evgeniy Polyakov wrote:
> On Tue, Feb 20, 2007 at 11:04:15AM +0100, Eric Dumazet (dada1@cosmosbay.com) 
wrote:
> > You totally miss the fact that the 1-2-4 MB cache is not available for
> > you at all. It is filled by User accesses. I dont care about DOS. I care
> > about real servers, servicing tcp clients. The TCP service/stack should
> > not take more than 10% of CPU (cycles and caches). The User application
> > is certainly more important because it hosts the real added value.
>
> TCP socket is 4k in size, one tree entry can be reduced to 200 bytes?
>
> No one says about _that_ cache miss, it is considered OK to have, but
> tree cache miss becomes the worst thing ever.
> In softirq we process socket's state, lock, reference counter several
> pointer, and if we are happy - the whole TCP state machine fields - and
> most of it stasy there when kernel is over - userspace issues syscalls
> which must populate it back. Why don't we see that it is moved into
> cache each time syscall is invoked? Because it is in the cache as long
> as part of the hash table assotiated with last recently used hash
> entries, which should not be there, and instead part of the tree can be.

No I see cache misses everywhere...

This is because my machines are doing real work in user land. They are not lab 
machines. Even if I had cpus with 16-32MB cache, it would be the same, 
because User land wants GBs ... 

For example, sock_wfree() uses 1.6612 % of cpu because of false sharing of 
sk_flags (dirtied each time SOCK_QUEUE_SHRUNK is set :(

ffffffff803c2850 <sock_wfree>: /* sock_wfree total: 714241  1.6613 */
  1307  0.0030 :ffffffff803c2850:       push   %rbp
 55056  0.1281 :ffffffff803c2851:       mov    %rsp,%rbp
    94 2.2e-04 :ffffffff803c2854:       push   %rbx
               :ffffffff803c2855:       sub    $0x8,%rsp
  1090  0.0025 :ffffffff803c2859:       mov    0x10(%rdi),%rbx
     3 7.0e-06 :ffffffff803c285d:       mov    0xb8(%rdi),%eax
    38 8.8e-05 :ffffffff803c2863:       lock sub %eax,0x90(%rbx)

/* HOT : access to sk_flags */
 81979  0.1907 :ffffffff803c286a:       mov    0x100(%rbx),%eax
512119  1.1912 :ffffffff803c2870:       test   $0x2,%ah

   262 6.1e-04 :ffffffff803c2873:       jne    ffffffff803c2880 
<sock_wfree+0x30>
   142 3.3e-04 :ffffffff803c2875:       mov    %rbx,%rdi
 14467  0.0336 :ffffffff803c2878:       callq  *0x200(%rbx)
    63 1.5e-04 :ffffffff803c287e:       data16
               :ffffffff803c287f:       nop    
  9046  0.0210 :ffffffff803c2880:       lock decl 0x28(%rbx)
 29792  0.0693 :ffffffff803c2884:       sete   %al
    56 1.3e-04 :ffffffff803c2887:       test   %al,%al
   789  0.0018 :ffffffff803c2889:       je     ffffffff803c2893 
<sock_wfree+0x43>
               :ffffffff803c288b:       mov    %rbx,%rdi
   144 3.3e-04 :ffffffff803c288e:       callq  ffffffff803c0f90 <sk_free>
  1685  0.0039 :ffffffff803c2893:       add    $0x8,%rsp
  2462  0.0057 :ffffffff803c2897:       pop    %rbx
   684  0.0016 :ffffffff803c2898:       leaveq 
  2963  0.0069 :ffffffff803c2899:       retq   


This is why tcp lookups should not take more than 1% themselves : other parts 
of the stack *want* to make many cache misses too.

If we want to optimize tcp, we should reorder fields to reduce number of cache 
lines, not change algos. struct sock fields are currently placed to reduce 
holes, while they should be grouped by related fields sharing cache lines.



