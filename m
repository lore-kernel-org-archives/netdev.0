From: jamal <hadi@cyberus.ca>
Subject: Re: dummy as IMQ replacement
Date: 20 Mar 2005 13:31:54 -0500
Message-ID: <1111343514.1092.55.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <0fcf01c5077f$579e4b80$6e69690a@RIMAS>
	 <1107174142.8021.121.camel@jzny.localdomain>
	 <00c301c524b4$938cd240$6e69690a@RIMAS>
	 <1110379135.1091.143.camel@jzny.localdomain>
	 <1110416767.1111.76.camel@jzny.localdomain>
	 <025501c52552$2dbf87c0$6e69690a@RIMAS>
	 <1110453757.1108.87.camel@jzny.localdomain> <423B7BCB.10400@dsl.pipex.com>
	 <1111196668.1146.114.camel@jzny.localdomain> <423BFD9F.50401@dsl.pipex.com>
	 <1111324805.1094.11.camel@jzny.localdomain>
	 <1111326913.1093.37.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-qx2mkIvoXQ+XYLg1iBzK"
Cc: Thomas Graf <tgraf@suug.ch>, Remus <rmocius@auste.elnet.lt>,
        netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Andre Tomt <andre@tomt.net>, syrius.ml@no-log.org,
        Damion de Soto <damion@snapgear.com>
To: Andy Furniss <andy.furniss@dsl.pipex.com>
In-Reply-To: <1111326913.1093.37.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-qx2mkIvoXQ+XYLg1iBzK
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


[Its amazing how much time i seem to have when i have no test machine].

Andy, dont bother trying to figure what kernels break. I think that
i may have found the bug though not 100% sure -its subtle but tricky.

I think my suspicion was correct - the stats changes that happened a
while back are causing havoc. Patch "p_kstats" should resolve a kernel
side bug introduced at the time. Patch "p_tcstats" for now should
resolve the tc side. I have not tested but was able to compile courtesy
of someones machine. 

cheers,
jamal

On Sun, 2005-03-20 at 08:55, jamal wrote:
> On Sun, 2005-03-20 at 08:20, jamal wrote:
> 
> > On Sat, 2005-03-19 at 05:23, Andy Furniss wrote:
> > 
> 
> > > [root@amd /home/andy/Qos]# tc -s filter ls dev eth0 parent ffff:
> > > 
> > > filter protocol ip pref 10 u32
> > > filter protocol ip pref 10 u32 fh 800: ht divisor 1
> > > filter protocol ip pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 
> > > flowid 1:1  (rule hit 12 success 12)
> > >    match 00000000/00000000 at 0 (success 12 )
> > >          action order 1: tablename: mangle  hook: NF_IP_PRE_ROUTING
> > >          target MARK set 0x1
> > >          index 1 ref 1 bind 1 installed 251 sec expires 1 sec
> > >          Action statistics:
> > >          Sent 7630953 bytes 0 pkt
> > >          rate 3146Kbit 1095565348pps
> > > 
> > 
> > Ok, this seems to be a bug in the stats - I think it may have been
> > introduced during the new kernel stats code updates.
> > Ive cced Thomas who added that code, he may be able to figure it oput
> > before i get back
> > 
> 
> OTOH, this may be a kernel issue. There have been some changes recently
> which updated some counters from 32 bit to 64 bit ;-> Clearly this
> will break the ABI and will give crap stats.
> 
> Try also if you can kernel 2.6.10.
> I think weve narrowed down iptables to be working if <= 1.2.11
> It will help me if you can narrow down the iproute2 version as well
> as the kernel version where things start breaking.
> 
> cheers,
> jamal
> 
> 
> 

--=-qx2mkIvoXQ+XYLg1iBzK
Content-Disposition: attachment; filename=p_kstats
Content-Type: text/plain; name=p_kstats; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- a/include/linux/rtnetlink.h	2005/03/20 17:53:07	1.1
+++ b/include/linux/rtnetlink.h	2005/03/20 17:53:34
@@ -699,7 +699,6 @@
 	TCA_RATE,
 	TCA_FCNT,
 	TCA_STATS2,
-	TCA_ACT_STATS,
 	__TCA_MAX
 };
 
--- a/include/linux/pkt_cls.h	2005/03/22 17:54:23	1.1
+++ b/include/linux/pkt_cls.h	2005/03/22 17:55:15
@@ -80,6 +80,7 @@
 	TCA_ACT_KIND,
 	TCA_ACT_OPTIONS,
 	TCA_ACT_INDEX,
+	TCA_ACT_STATS,
 	__TCA_ACT_MAX
 };
 

--=-qx2mkIvoXQ+XYLg1iBzK
Content-Disposition: attachment; filename=p_tcstats
Content-Type: text/plain; name=p_tcstats; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- a/include/linux/rtnetlink.h	2005/03/20 17:56:53	1.1
+++ b/include/linux/rtnetlink.h	2005/03/20 17:57:17
@@ -699,7 +699,6 @@
 	TCA_RATE,
 	TCA_FCNT,
 	TCA_STATS2,
-	TCA_ACT_STATS,
 	__TCA_MAX
 };
 
--- a/include/linux/pkt_cls.h	2005-03-20 08:45:44.000000000 -0500
+++ b/include/linux/pkt_cls.h	2005-03-20 12:56:19.000000000 -0500
@@ -78,6 +78,7 @@
 	TCA_ACT_KIND,
 	TCA_ACT_OPTIONS,
 	TCA_ACT_INDEX,
+	TCA_ACT_STATS,
 	__TCA_ACT_MAX
 };
 
@@ -136,9 +137,9 @@
 
 struct tcf_t
 {
-	__u32   install;
-	__u32   lastuse;
-	__u32   expires;
+	__u64   install;
+	__u64   lastuse;
+	__u64   expires;
 };
 
 struct tc_cnt

--=-qx2mkIvoXQ+XYLg1iBzK--
