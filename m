From: jamal <hadi@cyberus.ca>
Subject: Re: dummy as IMQ replacement
Date: 20 Mar 2005 08:20:05 -0500
Message-ID: <1111324805.1094.11.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <0fcf01c5077f$579e4b80$6e69690a@RIMAS>
	 <1107174142.8021.121.camel@jzny.localdomain>
	 <00c301c524b4$938cd240$6e69690a@RIMAS>
	 <1110379135.1091.143.camel@jzny.localdomain>
	 <1110416767.1111.76.camel@jzny.localdomain>
	 <025501c52552$2dbf87c0$6e69690a@RIMAS>
	 <1110453757.1108.87.camel@jzny.localdomain> <423B7BCB.10400@dsl.pipex.com>
	 <1111196668.1146.114.camel@jzny.localdomain> <423BFD9F.50401@dsl.pipex.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-HeZj/BB8k5iDZlF/HZDh"
Cc: Thomas Graf <tgraf@suug.ch>, Remus <rmocius@auste.elnet.lt>,
        netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Andre Tomt <andre@tomt.net>, syrius.ml@no-log.org,
        Damion de Soto <damion@snapgear.com>
To: Andy Furniss <andy.furniss@dsl.pipex.com>
In-Reply-To: <423BFD9F.50401@dsl.pipex.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-HeZj/BB8k5iDZlF/HZDh
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Andy,
Apologies again - I wont be able to get access to my test machine until
tuesday.

On Sat, 2005-03-19 at 05:23, Andy Furniss wrote:

> $TC filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
> match u32 0 0 flowid 1:1 \
> action ipt -j MARK --set-mark 1
> 
> It still gives memory error with 1.3.1 , with 1.2.11 it parses OK but I 
> get bogus stats - hit count is OK
> 
> [root@amd /home/andy/Qos]# tc -s filter ls dev eth0 parent ffff:
> 
> filter protocol ip pref 10 u32
> filter protocol ip pref 10 u32 fh 800: ht divisor 1
> filter protocol ip pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 
> flowid 1:1  (rule hit 12 success 12)
>    match 00000000/00000000 at 0 (success 12 )
>          action order 1: tablename: mangle  hook: NF_IP_PRE_ROUTING
>          target MARK set 0x1
>          index 1 ref 1 bind 1 installed 251 sec expires 1 sec
>          Action statistics:
>          Sent 7630953 bytes 0 pkt
>          rate 3146Kbit 1095565348pps
> 

Ok, this seems to be a bug in the stats - I think it may have been
introduced during the new kernel stats code updates.
Ive cced Thomas who added that code, he may be able to figure it oput
before i get back

> If I try with the lines below added
> 
> action egress redirect dev dummy0 or
> action redirect dev dummy0
> 
> I just get errors on whatever is after action - or memory errors with 1.3.1.
> 
> Using tc iproute2-ss050112 + patch for these tests.
> 

So if i have understood you correctly, with this version of tc and
version of iproute2, you have no problems other than stats being messed
up? i.e action ipt .. action mirred .. looks/works fine?

I think iptables >= 1.2.11 may have broken backward compatibility, i
will investigate when i get back. 
Lets narrow down to what version of iproute2 that things break - stick
with iptables 1.2.11

> I don't know if it's relevant but I am using gcc-2.95.3, which meant I 
> had to change the dummy patch a bit as it doesn't (for me) like variable 
> declarations in the middle of functions.
> 
> drivers/net/dummy.c: In function `dummy_xmit':
> drivers/net/dummy.c:218: parse error before `from'
> drivers/net/dummy.c:219: `from' undeclared (first use in this function)
> 
> So I changed to
> 
> static int dummy_xmit(struct sk_buff *skb, struct net_device *dev)
> {
> 	struct dummy_private *dp = ((struct net_device *)dev)->priv;
> 	struct net_device_stats *stats = &dp->stats;
> 	int ret = 0;
> 	__u32 from;
> 
> 	{
> 	stats->tx_packets++;
> 	stats->tx_bytes+=skb->len;
> 	}
> #ifdef CONFIG_NET_CLS_ACT
> 	from = G_TC_FROM(skb->tc_verd);
> 
> Is there a switch for this? - or am I the only one who actually does 
> kernel stuff with 2.95.3 (using LFS 5.1, which uses 3.3 by default but 
> keeps 2.95.3 in /opt specially for kernels)
> 

The change you have above is needed - dont recall of any gcc switches
which will resolve this.
I have fixed this for Remus as well back when he was testing (attached
dummy.c he is using); the stats are also a little misleading on whats rx
or tx. So those are fixed too in the attached version.

cheers,
jamal

--=-HeZj/BB8k5iDZlF/HZDh
Content-Disposition: attachment; filename=dummy.c.gz
Content-Type: application/x-gzip; name=dummy.c.gz
Content-Transfer-Encoding: base64

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

--=-HeZj/BB8k5iDZlF/HZDh--
