From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [PATCH] acx: make firmware statistics parsing more intelligent
Date: Sat, 4 Feb 2006 13:31:16 +0200
Message-ID: <200602041331.16308.vda@ilport.com.ua>
References: <20060203105857.GB11173@rhlx01.fht-esslingen.de>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andreas Mohr <andi@rhlx01.fht-esslingen.de>,
	netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: acx100-devel@lists.sourceforge.net
In-Reply-To: <20060203105857.GB11173@rhlx01.fht-esslingen.de>
Content-Disposition: inline
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

On Friday 03 February 2006 12:58, Andreas Mohr wrote:
> this patch does:
> - implement much more flexible firmware statistics parsing
>   (for /proc/driver/acx_wlanX_diag)
>   This has the nice effect that we now get output for both the older
>   TNETW1100 USB and TNETW1450.
>   Since firmware statistics information has non-stable layout depending on
>   firmware version, please report if you suspect any parsing mismatch!
>   This improved version now uses 2kB more driver space, unfortunately.
> - use "% 8" modulo instead of more complicated "% 5" calculation

Why? There will be HZ=100 and HZ=250 boxes, 8ms doesn't fit well.
10ms is ok, 5ms or 2.5ms is more or less ok too, but 8ms?

But I'll apply this anyway.

> - use
>     if (++idx >= count)
>       idx = 0;
>   instead of more bloaty
>     idx = (idx + 1) % count;
>   We might want to add a kernel macro for this *very* common and
>   performance-critical driver operation, say ring_advance_next or so,
>   in order to have the most optimized version for each architecture;
>   Or ($1 million question): Is there already such a beast somewhere!?

As discussed, just use unsigned variable and compile with -Os.


Patch applied to acx and acxsm with following edits:

        if (
            (IS_PCI(adev) && IS_ACX100(adev))
        ||  (IS_USB(adev) && IS_ACX100(adev))
        ) {

Replaced this with "if (IS_ACX100(adev)) {"

typedef struct fw_stats {
       u16                     type;
       u16                     len;
       fw_stats_tx_t           tx;
       fw_stats_rx_t           rx;
       fw_stats_dma_t          dma;
       fw_stats_irq_t          irq;
       fw_stats_wep_t          wep;
       fw_stats_pwr_t          pwr;
       fw_stats_mic_t          mic;
       fw_stats_aes_t          aes;
       fw_stats_event_t        evt;
+      u8                      _padding[FW_STATS_FUTURE_EXTENSION];
} fw_stats_t;

and removed "+FW_STATS_FUTURE_EXTENSION" elsewhere.

--
vda


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
