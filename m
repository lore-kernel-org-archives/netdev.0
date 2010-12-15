From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH 1/3] Kernel interfaces for multiqueue aware socket
Date: Wed, 15 Dec 2010 12:52:02 -0800
Message-ID: <4D092A72.2000401@intel.com>
References: <cover.1292405004.git.fenghua.yu@intel.com> <46a08278c2ba21737528eb4b77391a7e8bc88000.1292405004.git.fenghua.yu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Tang, Xinan" <xinan.tang@intel.com>,
	Junchang Wang <junchangwang@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: "Yu, Fenghua" <fenghua.yu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <46a08278c2ba21737528eb4b77391a7e8bc88000.1292405004.git.fenghua.yu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/15/2010 12:02 PM, Yu, Fenghua wrote:
> From: Fenghua Yu <fenghua.yu@intel.com>
> 
> Multiqueue and multicore provide packet parallel processing methodology.
> Current kernel and network drivers place one queue on one core. But the higher
> level socket doesn't know multiqueue. Current socket only can receive or send
> packets through one network interfaces. In some cases e.g. multi bpf filter
> tcpdump and snort, a lot of contentions come from socket operations like ring
> buffer. Even if the application itself has been fully parallelized and run on
> multi-core systems and NIC handlex tx/rx in multiqueue in parallel, network layer
> and NIC device driver assemble packets to a single, serialized queue. Thus the
> application cannot actually run in parallel in high speed.
> 
> To break the serialized packets assembling bottleneck in kernel, one way is to
> allow socket to know multiqueue associated with a NIC interface. So each socket
> can handle tx/rx in one queue in parallel.
> 
> Kernel provides several interfaces by which sockets can be bound to rx/tx queues.
> User applications can configure socket by providing several sockets that each
> bound to a single queue, applications can get data from kernel in parallel. After
> that, competitions mentioned above can be removed.
> 
> With this patch, the user-space receiving speed on a Intel SR1690 server with
> a single L5640 6-core processor and a single ixgbe-based NIC goes from 0.73Mpps
> to 4.20Mpps, nearly a linear speedup. A Intel SR1625 server two E5530 4-core
> processors and a single ixgbe-based NIC goes from 0.80Mpps to 4.6Mpps. We noticed
> the performance penalty comes from NUMA memory allocation.
> 
> This patch set provides kernel ioctl interfaces for user space. User space can
> either directly call the interfaces or libpcap interfaces can be further provided
> on the top of the kernel ioctl interfaces.
> 
> The order of tx/rx packets is up to user application. In some cases, e.g. network
> monitors, ordering is not a big problem because they more care how to receive and
> analyze packets in highest performance in parallel.
> 
> This patch set only implements multiqueue interfaces for AF_PACKET and Intel
> ixgbe NIC. Other protocols and NIC's can be handled on the top of this patch set.
> 
> Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>
> Signed-off-by: Junchang Wang <junchangwang@gmail.com>
> Signed-off-by: Xinan Tang <xinan.tang@intel.com>
> ---

I think it would be easier to manipulate the sk_hash to accomplish this. Allowing this from user space doesn't seem so great to me. You don't really want to pick the tx/rx bindings for sockets I think what you actually want is to optimize the hashing for this case to avoid the bottleneck you observe.

I'm not too familiar with the af_packet stuff but could you do this with a single flag that indicates the sk_hash should be set in {t}packet_snd(). Maybe I missed your point or there is a reason this wouldn't work. But, then you don't need to do funny stuff in select_queue and it works with rps/xps as well.

--John.
