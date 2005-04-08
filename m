From: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>
Subject: Re: pktgen problem (skb refcount) in 2.6.12-rc1
Date: Thu, 7 Apr 2005 18:15:09 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504071810380.4282-100000@localhost.localdomain>
References: <20050405155820.GB3261@obroa-skai.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>,
        Robert Olsson <Robert.Olsson@data.slu.se>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20050405155820.GB3261@obroa-skai.de.gnumonks.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 5 Apr 2005, Harald Welte wrote:

> 
> I have tried a 2.6.11 kernel which works fine.  I have not tested
> patching e1000 in 2.6.12-rc1 to go back to whatever was shipped in
> 2.6.11.
> 
> I'll try to remember testing that once I'm back from my current business
> trip (friday), though
> 

I think one of the previos set of e1000 patches is the cause for 
this issue. TSO workaround we put in doesn't release the last TX packet 
skb if there are no more receives on the interface.
 
Could you please try the below patch to 2.6.12-rc1? Apologies if the patch 
doesn't apply cleanly.

thanks,
Ayyappan V.

--- linux-2.6.11.6/drivers/net/e1000/e1000_main.c.fix1	2005-04-04 22:08:13.026941064 -0700
+++ linux-2.6.11.6/drivers/net/e1000/e1000_main.c	2005-04-04 22:07:18.775188584 -0700
@@ -2426,6 +2426,14 @@
 		   !(E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_TXOFF))
 			netif_stop_queue(netdev);
 	}
+#ifdef NETIF_F_TSO
+
+	if( unlikely(!(eop_desc->upper.data & cpu_to_le32(E1000_TXD_STAT_DD)) &&
+	    time_after(jiffies, adapter->previous_buffer_info.time_stamp + HZ)))
+		e1000_unmap_and_free_tx_resource(
+		    adapter, &adapter->previous_buffer_info);
+
+#endif
 
 	return cleaned;
 }
