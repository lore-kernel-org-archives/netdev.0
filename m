From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: pc300too on a modern kernel?
Date: Mon, 22 Nov 2010 22:20:02 +0100
Message-ID: <m38w0l2gzh.fsf@intrepid.localdomain>
References: <20100902131531.GA19028@countzero.vandewege.net>
	<m3mxrw1lg0.fsf@intrepid.localdomain>
	<1289421869.9336.49.camel@giskard.codewiz.org>
	<m3sjz34mka.fsf@intrepid.localdomain>
	<1289944619.2677.22.camel@giskard.codewiz.org>
	<m3tyjd7za9.fsf@intrepid.localdomain>
	<1290442675.5515.92.camel@giskard.codewiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ward Vandewege <ward@gnu.org>, lkml <linux-kernel@vger.kernel.org>,
	Jan Seiffert <kaffeemonster@googlemail.com>,
	netdev@vger.kernel.org
To: Bernie Innocenti <bernie@codewiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1290442675.5515.92.camel@giskard.codewiz.org> (Bernie
	Innocenti's message of "Mon, 22 Nov 2010 11:17:55 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(added Cc: netdev)

Bernie Innocenti <bernie@codewiz.org> writes:

> Now the question is: why do we get so many spurious interrupts?

Let me see... we call sca_tx_done() on (isr0 & 0x2020) which are DMIB3
and DMIB1, which in turn are (EOT & (EOTE = 0) | EOM & (EOME = 1)), i.e.
the interrupt is generated on EOM (end of message = packet).

It seems TN-PSC-339A/E is the answer: the interrupt is generated at the
end of the last DMA access filling the TX buffer. Only then the status
is written to the descriptor (=RAM). I guess it didn't make a difference
on older, slower machines, with slower paths from PCI to CPU.
Also I don't know if the descriptor status is being written in the same
DMA transfer (between the chip and on-board SRAM) as the last data
transfer. Perhaps it's another DMA request and arbitration, and perhaps
the chip has to wait for another transfer to finish.

> With this workaround applied, we're st seeing occasional clusters of
> packet loss. We're working to graph the ping loss alongside traffic to
> see if there's any correlation.

That's interesting. I remember seeing some TX underruns at higher
speeds, though nothing alike at 2 Mb/s. What bit rate are you using?
Does "ifconfig hdlc0" show any errors?
-- 
Krzysztof Halasa
