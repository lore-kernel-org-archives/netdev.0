From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Date: Tue, 14 Feb 2017 13:12:06 +0100
Message-ID: <20170214131206.44b644f6@redhat.com>
References: <20170213195858.5215-1-edumazet@google.com>
	<20170213195858.5215-9-edumazet@google.com>
	<CAKgT0Ufx0Y=9kjLax36Gx4e7Y-A7sKZDNYxgJ9wbCT4_vxHhGA@mail.gmail.com>
	<CANn89iLkPB_Dx1L2dFfwOoeXOmPhu_C3OO2yqZi8+Rvjr=-EtA@mail.gmail.com>
	<CAKgT0UeB_e_Z7LM1_r=en8JJdgLhoYFstWpCDQN6iawLYZJKDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        "David S . Miller"
 <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Tariq Toukan
 <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>, Saeed Mahameed
 <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Brenden
 Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric
 Dumazet <eric.dumazet@gmail.com>, brouer@redhat.com,
        linux-mm
 <linux-mm@kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <CAKgT0UeB_e_Z7LM1_r=en8JJdgLhoYFstWpCDQN6iawLYZJKDA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org


On Mon, 13 Feb 2017 15:16:35 -0800
Alexander Duyck <alexander.duyck@gmail.com> wrote:

[...]
> ... As I'm sure Jesper will probably point out the atomic op for
> get_page/page_ref_inc can be pretty expensive if I recall correctly.

It is important to understand that there are two cases for the cost of
an atomic op, which depend on the cache-coherency state of the
cacheline.

Measured on Skylake CPU i7-6700K CPU @ 4.00GHz

(1) Local CPU atomic op :  27 cycles(tsc)  6.776 ns
(2) Remote CPU atomic op: 260 cycles(tsc) 64.964 ns

Notice the huge difference. And in case 2, it is enough that the remote
CPU reads the cacheline and brings it into "Shared" (MESI) state, and
the local CPU then does the atomic op.

One key ideas behind the page_pool, is that remote CPUs read/detect
refcnt==1 (Shared-state), and store the page in a small per-CPU array.
When array is full, it gets bulk returned to the shared-ptr-ring pool.
When "local" CPU need new pages, from the shared-ptr-ring it prefetchw
during it's bulk refill, to latency-hide the MESI transitions needed.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
