From: Andy Furniss <andy.furniss@dsl.pipex.com>
Subject: Re: dummy as IMQ replacement
Date: Sat, 19 Mar 2005 10:23:27 +0000
Message-ID: <423BFD9F.50401@dsl.pipex.com>
References: <1107123123.8021.80.camel@jzny.localdomain>	 <0fcf01c5077f$579e4b80$6e69690a@RIMAS>	 <1107174142.8021.121.camel@jzny.localdomain>	 <00c301c524b4$938cd240$6e69690a@RIMAS>	 <1110379135.1091.143.camel@jzny.localdomain>	 <1110416767.1111.76.camel@jzny.localdomain>	 <025501c52552$2dbf87c0$6e69690a@RIMAS>	 <1110453757.1108.87.camel@jzny.localdomain>  <423B7BCB.10400@dsl.pipex.com> <1111196668.1146.114.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Remus <rmocius@auste.elnet.lt>, netdev@oss.sgi.com,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
To: hadi@cyberus.ca
In-Reply-To: <1111196668.1146.114.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> Remus seems to have got it working with iptables earlier than
> 1.3.0 works fine.
> Unfortunately i am not close to my machines and wont be for a while.
> Can you try not to pass mirred in the command line and see if that
> works?
> 
> cheers,
> jamal

If I just do -

....
$TC filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
match u32 0 0 flowid 1:1 \
action ipt -j MARK --set-mark 1

It still gives memory error with 1.3.1 , with 1.2.11 it parses OK but I 
get bogus stats - hit count is OK

[root@amd /home/andy/Qos]# tc -s filter ls dev eth0 parent ffff:

filter protocol ip pref 10 u32
filter protocol ip pref 10 u32 fh 800: ht divisor 1
filter protocol ip pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 
flowid 1:1  (rule hit 12 success 12)
   match 00000000/00000000 at 0 (success 12 )
         action order 1: tablename: mangle  hook: NF_IP_PRE_ROUTING
         target MARK set 0x1
         index 1 ref 1 bind 1 installed 251 sec expires 1 sec
         Action statistics:
         Sent 7630953 bytes 0 pkt
         rate 3146Kbit 1095565348pps

If I try with the lines below added

action egress redirect dev dummy0 or
action redirect dev dummy0

I just get errors on whatever is after action - or memory errors with 1.3.1.

Using tc iproute2-ss050112 + patch for these tests.

I don't know if it's relevant but I am using gcc-2.95.3, which meant I 
had to change the dummy patch a bit as it doesn't (for me) like variable 
declarations in the middle of functions.

drivers/net/dummy.c: In function `dummy_xmit':
drivers/net/dummy.c:218: parse error before `from'
drivers/net/dummy.c:219: `from' undeclared (first use in this function)

So I changed to

static int dummy_xmit(struct sk_buff *skb, struct net_device *dev)
{
	struct dummy_private *dp = ((struct net_device *)dev)->priv;
	struct net_device_stats *stats = &dp->stats;
	int ret = 0;
	__u32 from;

	{
	stats->tx_packets++;
	stats->tx_bytes+=skb->len;
	}
#ifdef CONFIG_NET_CLS_ACT
	from = G_TC_FROM(skb->tc_verd);

Is there a switch for this? - or am I the only one who actually does 
kernel stuff with 2.95.3 (using LFS 5.1, which uses 3.3 by default but 
keeps 2.95.3 in /opt specially for kernels)

I am using it for iptables and tc aswell (though I tried 3.3 - but not 
for kernel yet)

I have manually loaded modules

dummy                   3972  0
mirred                  6400  0
pedit                   6624  0
gact                    5984  0
ipt_MARK                2432  0
ipt                     6944  0
ip_tables              19728  2 ipt_MARK,ipt
sch_tbf                 5120  1
sch_ingress             3136  1
cls_fw                  3904  2
sch_sfq                 5184  2
sch_prio                4736  1
cls_u32                 6916  0

Andy.
