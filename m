From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] udp reuseport: fix packet of same flow hashed to
 different socket
Date: Tue, 14 Jun 2016 18:52:18 -0400 (EDT)
Message-ID: <20160614.185218.740886012015736280.davem@davemloft.net>
References: <1465786970-10157-1-git-send-email-suxm@chinanetcenter.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, edumazet@google.com
To: suxm@chinanetcenter.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465786970-10157-1-git-send-email-suxm@chinanetcenter.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Su Xuemin <suxm@chinanetcenter.com>
Date: Mon, 13 Jun 2016 11:02:50 +0800

> From: "Su, Xuemin" <suxm@chinanetcenter.com>
> 
> There is a corner case in which udp packets belonging to a same
> flow are hashed to different socket when hslot->count changes from 10
> to 11:
> 
> 1) When hslot->count <= 10, __udp_lib_lookup() searches udp_table->hash,
> and always passes 'daddr' to udp_ehashfn().
> 
> 2) When hslot->count > 10, __udp_lib_lookup() searches udp_table->hash2,
> but may pass 'INADDR_ANY' to udp_ehashfn() if the sockets are bound to
> INADDR_ANY instead of some specific addr.
> 
> That means when hslot->count changes from 10 to 11, the hash calculated by
> udp_ehashfn() is also changed, and the udp packets belonging to a same
> flow will be hashed to different socket.
> 
> This is easily reproduced:
> 1) Create 10 udp sockets and bind all of them to 0.0.0.0:40000.
> 2) From the same host send udp packets to 127.0.0.1:40000, record the
> socket index which receives the packets.
> 3) Create 1 more udp socket and bind it to 0.0.0.0:44096. The number 44096
> is 40000 + UDP_HASH_SIZE(4096), this makes the new socket put into the
> same hslot as the aformentioned 10 sockets, and makes the hslot->count
> change from 10 to 11.
> 4) From the same host send udp packets to 127.0.0.1:40000, and the socket
> index which receives the packets will be different from the one received
> in step 2.
> This should not happen as the socket bound to 0.0.0.0:44096 should not
> change the behavior of the sockets bound to 0.0.0.0:40000.
> 
> It's the same case for IPv6, and this patch also fixes that.
> 
> Signed-off-by: Su, Xuemin <suxm@chinanetcenter.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
