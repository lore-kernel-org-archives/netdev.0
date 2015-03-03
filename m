From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bcm63xx_enet: fix poll callback.
Date: Tue, 03 Mar 2015 05:29:59 -0800
Message-ID: <1425389399.5130.169.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425383112-23851-1-git-send-email-nschichan@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Tobias Klauser <tklauser@distanz.ch>,
	Felipe Balbi <balbi@ti.com>,
	Wilfried Klaebe <w-lkml@lebenslange-mailadresse.de>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicolas Schichan <nschichan@freebox.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425383112-23851-1-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-03-03 at 12:45 +0100, Nicolas Schichan wrote:
> In case there was some tx buffer reclaimed and not enough rx packets
> to consume the whole budget, napi_complete would not be called and
> interrupts would be kept disabled, effectively resulting in the
> network core never to call the poll callback again and no rx/tx
> interrupts to be fired either.
> 
> Fix that by only accounting the rx work done in the poll callback.
> 
> Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
> ---

This looks better, thanks.

Acked-by: Eric Dumazet <edumazet@google.com>

Note that the way bcm_enet_tx_reclaim() is written, it can livelock on
SMP hosts :

CPU 1,2,3,...  keep queuing packets via ndo_start_xmit()

CPU 0 is looping forever in bcm_enet_tx_reclaim() draining queue and
freeing skbs.

To avoid that, I would take priv->tx_lock only once, or add a limit on
the number of skbs that can be drained per round.
