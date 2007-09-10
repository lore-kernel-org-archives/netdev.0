From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Mon, 10 Sep 2007 08:09:08 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0709100807260.16478@woody.linux-foundation.org>
References: <18115.52863.638655.658466@cargo.ozlabs.ibm.com>
 <6370BBDF-0C79-41EB-BD2A-02AA0D216924@mac.com> <200709101438.36710.vda.linux@googlemail.com>
 <200709101516.03234.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Kyle Moffett <mrmacman_g4@mac.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Nick Piggin <piggin@cyberone.com.au>,
	Satyam Sharma <satyam@infradead.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Mackerras <paulus@samba.org>,
	Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, ak@suse.de,
	heiko.carstens@de.ibm.com, David Miller <davem@davemloft.net>,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Denys Vlasenko <vda.linux@googlemail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760804AbXIJPMO@vger.kernel.org>
In-Reply-To: <200709101516.03234.vda.linux@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 10 Sep 2007, Denys Vlasenko wrote:
> 
> static inline int
> qla2x00_wait_for_loop_ready(scsi_qla_host_t *ha)
> {
>         int      return_status = QLA_SUCCESS;
>         unsigned long loop_timeout ;
>         scsi_qla_host_t *pha = to_qla_parent(ha);
> 
>         /* wait for 5 min at the max for loop to be ready */
>         loop_timeout = jiffies + (MAX_LOOP_TIMEOUT * HZ);
> 
>         while ((!atomic_read(&pha->loop_down_timer) &&
>             atomic_read(&pha->loop_state) == LOOP_DOWN) ||
>             atomic_read(&pha->loop_state) != LOOP_READY) {
>                 if (atomic_read(&pha->loop_state) == LOOP_DEAD) {
...
> Is above correct or buggy? Correct, because msleep is a barrier.
> Is it obvious? No.

It's *buggy*. But it has nothing to do with any msleep() in the loop, or 
anything else.

And more importantly, it would be equally buggy even *with* a "volatile" 
atomic_read().

Why is this so hard for people to understand? You're all acting like 
morons.

The reason it is buggy has absolutely nothing to do with whether the read 
is done or not, it has to do with the fact that the CPU may re-order the 
reads *regardless* of whether the read is done in some specific order by 
the compiler ot not! In effect, there is zero ordering between all those 
three reads, and if you don't have memory barriers (or a lock or other 
serialization), that code is buggy.

So stop this idiotic discussion thread already. The above kind of code 
needs memory barriers to be non-buggy. The whole "volatile or not" 
discussion is totally idiotic, and pointless, and anybody who doesn't 
understand that by now needs to just shut up and think about it more, 
rather than make this discussion drag out even further.

The fact is, "volatile" *only* makes things worse. It generates worse 
code, and never fixes any real bugs. This is a *fact*.

			Linus
