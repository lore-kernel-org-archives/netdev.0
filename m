From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Mon, 10 Sep 2007 15:16:02 +0100
Message-ID: <200709101516.03234.vda.linux@googlemail.com>
References: <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <6370BBDF-0C79-41EB-BD2A-02AA0D216924@mac.com> <200709101438.36710.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@infradead.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
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
	segher@kernel.crashing
To: Kyle Moffett <mrmacman_g4@mac.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.229]:41635 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759967AbXIJOQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 10:16:14 -0400
Received: by qb-out-0506.google.com with SMTP id e11so1107404qbe
        for <netdev@vger.kernel.org>; Mon, 10 Sep 2007 07:16:13 -0700 (PDT)
In-Reply-To: <200709101438.36710.vda.linux@googlemail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 10 September 2007 14:38, Denys Vlasenko wrote:
> You are basically trying to educate me how to use atomic properly.
> You don't need to do it, as I am (currently) not a driver author.
> 
> I am saying that people who are already using atomic_read()
> (and who unfortunately did not read your explanation above)
> will still sometimes use atomic_read() as a way to read atomic value
> *from memory*, and will create nasty heisenbugs for you to debug.

static inline int
qla2x00_wait_for_loop_ready(scsi_qla_host_t *ha)
{
        int      return_status = QLA_SUCCESS;
        unsigned long loop_timeout ;
        scsi_qla_host_t *pha = to_qla_parent(ha);

        /* wait for 5 min at the max for loop to be ready */
        loop_timeout = jiffies + (MAX_LOOP_TIMEOUT * HZ);

        while ((!atomic_read(&pha->loop_down_timer) &&
            atomic_read(&pha->loop_state) == LOOP_DOWN) ||
            atomic_read(&pha->loop_state) != LOOP_READY) {
                if (atomic_read(&pha->loop_state) == LOOP_DEAD) {
                        return_status = QLA_FUNCTION_FAILED;
                        break;
                }
                msleep(1000);
                if (time_after_eq(jiffies, loop_timeout)) {
                        return_status = QLA_FUNCTION_FAILED;
                        break;
                }
        }
        return (return_status);
}

Is above correct or buggy? Correct, because msleep is a barrier.
Is it obvious? No.

static void
qla2x00_rst_aen(scsi_qla_host_t *ha)
{
        if (ha->flags.online && !ha->flags.reset_active &&
            !atomic_read(&ha->loop_down_timer) &&
            !(test_bit(ABORT_ISP_ACTIVE, &ha->dpc_flags))) {
                do {
                        clear_bit(RESET_MARKER_NEEDED, &ha->dpc_flags);

                        /*
                         * Issue marker command only when we are going to start
                         * the I/O.
                         */
                        ha->marker_needed = 1;
                } while (!atomic_read(&ha->loop_down_timer) &&
                    (test_bit(RESET_MARKER_NEEDED, &ha->dpc_flags)));
        }
}

Is above correct? I honestly don't know. Correct, because set_bit is
a barrier on _all _memory_? Will it break if set_bit will be changed
to be a barrier only on its operand? Probably yes.

drivers/kvm/kvm_main.c

        while (atomic_read(&completed) != needed) {
                cpu_relax();
                barrier();
        }

Obviously author did not know that cpu_relax is already a barrier.
See why I think driver authors will be confused?

arch/x86_64/kernel/crash.c

static void nmi_shootdown_cpus(void)
{
...
        msecs = 1000; /* Wait at most a second for the other cpus to stop */
        while ((atomic_read(&waiting_for_crash_ipi) > 0) && msecs) {
                mdelay(1);
                msecs--;
        }
...
}

Is mdelay(1) a barrier? Yes, because it is a function on x86_64.
Absolutely the same code will be buggy on an arch where
mdelay(1) == udelay(1000), and udelay is implemented
as inline busy-wait.

arch/sparc64/kernel/smp.c

        /* Wait for response */
        while (atomic_read(&data.finished) != cpus)
                cpu_relax();
...later in the same file...
                while (atomic_read(&smp_capture_registry) != ncpus)
                        rmb();

I'm confused. Do we need cpu_relax() or rmb()? Does cpu_relax() imply rmb()?
(No it doesn't). Which of those two while loops needs correcting?
--
vda
