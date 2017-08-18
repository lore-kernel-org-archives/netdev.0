From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: export drops counter to /proc/net/tcp{,6}
Date: Fri, 18 Aug 2017 05:14:04 -0700
Message-ID: <1503058444.4936.169.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170818102135.266832-1-sgorget@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Jeethu Rao <jeethu@fb.com>,
        "David S . Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>,
        Eric Dumazet <edumazet@google.com>, kernel-team@fb.com,
        linux-kernel@vger.kernel.org
To: =?ISO-8859-1?Q?St=E9phan?= Gorget <sgorget@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170818102135.266832-1-sgorget@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-08-18 at 03:21 -0700, Stéphan Gorget wrote:
> Those counters are exported for raw and udp but not for tcp, though they
> are incremented.
> 
> An example where it is useful is chasing listen overflow. Listen overflow
> are counted as a global counter in LINUX_MIB_LISTENOVERFLOWS accessible
> in /proc/net/netstat but there is no way to find related drops in the
> information exported for tcp. With this patch it will make possible to
> correlate growth of LINUX_MIB_LISTENOVERFLOWS with growth of drops for
> a tcp socket.

Hi Stéphan.

Eons ago, the decision was taken to declare /proc interface frozen.

In linux-4.7 I provided all the information you need using the modern
inet_diag interface, [1]

Simply use iproute2/ss tool to access this information in a very
efficient way (like filtering done in the kernel, instead having to
parse a gigantic /proc output)

lpaa5:~# ss -tm state listening src :22
Recv-Q Send-Q Local Address:Port                 Peer Address:Port                
0      128             *:ssh                           *:*                    
	 skmem:(r0,rb8388608,t0,tb8388608,f0,w0,o0,bl0,d7)
0      128            :::ssh                          :::*                    
	 skmem:(r0,rb8388608,t0,tb8388608,f0,w0,o0,bl0,d0)

You can see here that the IPv4 listener for ssh had 7 drops.

Thanks.

[1] list of relevant commits.

commit 9caad864151e525929d323de96cad382da49c3b2
Author: Eric Dumazet <edumazet@google.com>
Date:   Fri Apr 1 08:52:20 2016 -0700

    tcp: increment sk_drops for listeners
    
    Goal: packets dropped by a listener are accounted for.
    
    This adds tcp_listendrop() helper, and clears sk_drops in sk_clone_lock()
    so that children do not inherit their parent drop count.
    
    Note that we no longer increment LINUX_MIB_LISTENDROPS counter when
    sending a SYNCOOKIE, since the SYN packet generated a SYNACK.
    We already have a separate LINUX_MIB_SYNCOOKIESSENT
    
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 532182cd610782db8c18230c2747626562032205
Author: Eric Dumazet <edumazet@google.com>
Date:   Fri Apr 1 08:52:19 2016 -0700

    tcp: increment sk_drops for dropped rx packets
    
    Now ss can report sk_drops, we can instruct TCP to increment
    this per socket counter when it drops an incoming frame, to refine
    monitoring and debugging.
    
    Following patch takes care of listeners drops.
    
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 15239302edd46b184e758048253541fb211e315e
Author: Eric Dumazet <edumazet@google.com>
Date:   Fri Apr 1 08:52:18 2016 -0700

    sock_diag: add SK_MEMINFO_DROPS
    
    Reporting sk_drops to user space was available for UDP
    sockets using /proc interface.
    
    Add this to sock_diag, so that we can have the same information
    available to ss users, and we'll be able to add sk_drops
    indications for TCP sockets as well.
    
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
