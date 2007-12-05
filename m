From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 7/7][TAKE 2][TFRC] New rx history code
Date: Wed, 5 Dec 2007 09:42:37 +0000
Message-ID: <20071205094237.GB5177@gerrit.erg.abdn.ac.uk>
References: <1196631416-17778-2-git-send-email-acme@redhat.com> <1196631416-17778-3-git-send-email-acme@redhat.com> <1196631416-17778-4-git-send-email-acme@redhat.com> <1196631416-17778-5-git-send-email-acme@redhat.com> <1196631416-17778-6-git-send-email-acme@redhat.com> <1196631416-17778-7-git-send-email-acme@redhat.com> <1196631416-17778-8-git-send-email-acme@redhat.com> <20071204065517.GA4404@gerrit.erg.abdn.ac.uk> <20071204115939.GA18084@ghostprotocols.net> <20071204134810.GB18084@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>, netdev@vger.kernel.org,
	dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:58756 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751644AbXLEJnW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 04:43:22 -0500
Content-Disposition: inline
In-Reply-To: <20071204134810.GB18084@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| I found a problem that I'm still investigating if was introduced by this
| patch or if was already present. When sending 1 million 256 byte packets
| with ttcp over loopback, using ccid3 it is crashing, the test machine
| I'm using doesn't have a serial port, its a notebook, will switch to
| another that has and provide the backtrace. It doesn't happens every
| time.
| 
CCID3 is difficult due to the TX queue. Small packets are faster on the
wire, fill up the TX queue faster. Since there is little loss on LANs, 
the slow-start algorithm will soon reach link capacity; but CCID3 can
not deal effectively with high speeds.
What is known not to work well at the moment is bidirectional data
transfer (e.g. an echo server/client). This lead to the comment in
tfrc_rx_sample_rtt(); the support for bidirectional data transfer
needs some more work, which however requires to make one-directional
transfer work well first.

| Here is tfrc_rx_hist_alloc back using ring of pointers with the fixed
| error path.
| 
Thank you - I was just about to send a similar patch as update since
you clearly identified this bug. I will resubmit with your version
and upload it to the test tree.


| +int tfrc_rx_hist_alloc(struct tfrc_rx_hist *h)
|  {
| +	int i;
| +
| +	for (i = 0; i <= TFRC_NDUPACK; i++) {
| +		h->ring[i] = kmem_cache_alloc(tfrc_rx_hist_slab, GFP_ATOMIC);
| +		if (h->ring[i] == NULL)
| +			goto out_free;
| +	}
| +
| +	h->loss_count = h->loss_start = 0;
| +	return 0;
| +
| +out_free:
| +	while (i-- != 0) {
| +		kmem_cache_free(tfrc_rx_hist_slab, h->ring[i]);
| +		h->ring[i] = NULL;
|  	}
| +	return -ENOBUFS;
|  }
| 
