From: "Raghavendra Koushik" <raghavendra.koushik@neterion.com>
Subject: RE: [PATCH 2.6.12.1 5/12] S2io: Performance improvements
Date: Thu, 7 Jul 2005 18:06:19 -0700
Message-ID: <200507080106.j6816NKP022996@guinness.s2io.com>
References: <Pine.LNX.4.61.0507071552130.24321@resonance.WorkGroup>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <jgarzik@pobox.com>, <netdev@oss.sgi.com>, <netdev@vger.kernel.org>,
        <ravinandan.arakali@neterion.com>, <leonid.grossman@neterion.com>,
        <rapuru.sriram@neterion.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Arthur Kepner'" <akepner@sgi.com>
In-Reply-To: <Pine.LNX.4.61.0507071552130.24321@resonance.WorkGroup>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I thought that an mmiowb() was called for here (to order the PIO 
> writes above more cheaply than doing the readq()). I posted a 
> patch like this some time ago:
> 
> http://marc.theaimsgroup.com/?l=linux-netdev&m=111508292028110&w=2

On an Altix machine I believe the readq was necessary to flush 
the PIO writes. How long did you run the tests? I had seen
in long duration tests that an occasional write 
(TXDL control word and the address) would be missed and the xmit
Get's stuck.


> 
> FWIW, I've done quite a few performance measurements with the patch 
> I posted earlier, and it's worked well. For 1500 byte mtus throughput 
> goes up by ~20%. Is even the mmiowb() unnecessary?
> 

Was this on 2.4 kernel because I think the readq would not have a 
significant impact on 2.6 kernels due to TSO.
(with TSO on the number of packets that actually enter the 
Xmit routine would be reduced apprx 40 times).

> What is the wmb() above for?
wmb() is to ensure ordered PIO writes.

Thanks
- Koushik

 

> -----Original Message-----
> From: Arthur Kepner [mailto:akepner@sgi.com] 
> Sent: Thursday, July 07, 2005 4:15 PM
> To: raghavendra.koushik@neterion.com
> Cc: jgarzik@pobox.com; netdev@oss.sgi.com; 
> netdev@vger.kernel.org; ravinandan.arakali@neterion.com; 
> leonid.grossman@neterion.com; rapuru.sriram@neterion.com
> Subject: Re: [PATCH 2.6.12.1 5/12] S2io: Performance improvements
> 
> 
> On Thu, 7 Jul 2005 raghavendra.koushik@neterion.com wrote:
> 
> > .......
> > 2. Removed unnecessary PIOs(read/write of tx_traffic_int and 
> >    rx_traffic_int) from interrupt handler and removed read of
> >    general_int_status register from xmit routine.		
> 	    
> > ......
> > @@ -2891,6 +2869,8 @@ int s2io_xmit(struct sk_buff *skb, struc
> >  	val64 = 
> mac_control->fifos[queue].list_info[put_off].list_phy_addr;
> >  	writeq(val64, &tx_fifo->TxDL_Pointer);
> >  
> > +	wmb();
> > +
> >  	val64 = (TX_FIFO_LAST_TXD_NUM(frg_cnt) | TX_FIFO_FIRST_LIST |
> >  		 TX_FIFO_LAST_LIST);
> >  
> > @@ -2900,9 +2880,6 @@ int s2io_xmit(struct sk_buff *skb, struc
> >  #endif
> >  	writeq(val64, &tx_fifo->List_Control);
> >  
> > -	/* Perform a PCI read to flush previous writes */
> > -	val64 = readq(&bar0->general_int_status);
> > -
> >  	put_off++;
>                                                                   
> I thought that an mmiowb() was called for here (to order the PIO 
> writes above more cheaply than doing the readq()). I posted a 
> patch like this some time ago:
> 
> http://marc.theaimsgroup.com/?l=linux-netdev&m=111508292028110&w=2
> 
> FWIW, I've done quite a few performance measurements with the patch 
> I posted earlier, and it's worked well. For 1500 byte mtus throughput 
> goes up by ~20%. Is even the mmiowb() unnecessary?
> 
> What is the wmb() above for?
> 
> --
> Arthur
> 
