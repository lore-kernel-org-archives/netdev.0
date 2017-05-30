From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH V2 2/3] net-next: dsa: add multi cpu port support
Date: Tue, 30 May 2017 12:23:14 -0700
Message-ID: <39b72ae8-eafd-a984-05d1-0327088fa1e8@gmail.com>
References: <201705302336.BC8366CF%fengguang.wu@intel.com>
 <7d8cdddb-f107-9945-f366-12d320ecb188@phrozen.org>
 <979a011e-0f41-a919-9d46-1f8258b645af@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: John Crispin <john@phrozen.org>, kbuild test robot <lkp@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <979a011e-0f41-a919-9d46-1f8258b645af@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/30/2017 12:15 PM, Florian Fainelli wrote:
> Hi John,
> 
> On 05/30/2017 11:37 AM, John Crispin wrote:
>> Hi,
>>
>> the patch series is based on net-next from 12 hours ago and works fine
>> on that tree. I compile and runtime tested it quite intensively on
>> various boards
> 
> The warning is legit though:
> 
>     572            if (dsa_port_is_cpu(port))
>     573                err = dsa_cpu_parse(port, index, dst, ds);
>   > 574            else if (dsa_is_normal_port(port))
>     575                err = dsa_user_parse(port->dn, index,  ds);
> 
> and after applying your patches I also met it:
> 
> net/dsa/dsa2.c: In function 'dsa_ds_parse':
> net/dsa/dsa2.c:574:3: warning: passing argument 1 of
> 'dsa_is_normal_port' from incompatible pointer type [enabled by default]
>    else if (dsa_is_normal_port(port))
>    ^
> In file included from net/dsa/dsa_priv.h:17:0,
>                  from net/dsa/dsa2.c:22:
> ./include/net/dsa.h:264:20: note: expected 'struct dsa_switch *' but
> argument is of type 'struct dsa_port *'
>  static inline bool dsa_is_normal_port(struct dsa_switch *ds, int p)
>                     ^
> net/dsa/dsa2.c:574:3: error: too few arguments to function
> 'dsa_is_normal_port'
>    else if (dsa_is_normal_port(port))
>    ^
> In file included from net/dsa/dsa_priv.h:17:0,
>                  from net/dsa/dsa2.c:22:
> ./include/net/dsa.h:264:20: note: declared here
>  static inline bool dsa_is_normal_port(struct dsa_switch *ds, int p)
>                     ^
>   CC      net/bridge/br_stp.o
> scripts/Makefile.build:302: recipe for target 'net/dsa/dsa2.o' failed
> make[4]: *** [net/dsa/dsa2.o] Error 1
> scripts/Makefile.build:561: recipe for target 'net/dsa' failed
> make[3]: *** [net/dsa] Error 2
> make[3]: *** Waiting for unfinished jobs....
> 
> We need something like this, I have some comments on your patches that I
> will send shortly. Thanks!
> 
> diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
> index 8b13aa735c40..124c5acfa123 100644
> --- a/net/dsa/dsa2.c
> +++ b/net/dsa/dsa2.c
> @@ -539,14 +539,14 @@ static int dsa_cpu_parse(struct dsa_port *port,
> u32 index,
>         return 0;
>  }
> 
> -static int dsa_user_parse(struct device_node *port, u32 index,
> +static int dsa_user_parse(struct dsa_port *port, u32 index,
>                           struct dsa_switch *ds)
>  {
>         struct device_node *cpu_port;
>         const unsigned int *cpu_port_reg;
>         int cpu_port_index;
> 
> -       cpu_port = of_parse_phandle(port, "cpu", 0);
> +       cpu_port = of_parse_phandle(port->dn, "cpu", 0);
>         if (cpu_port) {
>                 cpu_port_reg = of_get_property(cpu_port, "reg", NULL);
>                 if (!cpu_port_reg)
> @@ -572,7 +572,7 @@ static int dsa_ds_parse(struct dsa_switch_tree *dst,
> struct dsa_switch *ds)
>                 if (dsa_port_is_cpu(port))
>                         err = dsa_cpu_parse(port, index, dst, ds);
>                 else if (dsa_is_normal_port(port))
> -                       err = dsa_user_parse(port->dn, index,  ds);
> +                       err = dsa_user_parse(port, index,  ds);
> 
>                         if (err)
>                                 return err;

here is a version that builds, I missed one hunk:

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 8b13aa735c40..d71a2a610340 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -539,14 +539,14 @@ static int dsa_cpu_parse(struct dsa_port *port,
u32 index,
        return 0;
 }

-static int dsa_user_parse(struct device_node *port, u32 index,
+static int dsa_user_parse(struct dsa_port *port, u32 index,
                          struct dsa_switch *ds)
 {
        struct device_node *cpu_port;
        const unsigned int *cpu_port_reg;
        int cpu_port_index;

-       cpu_port = of_parse_phandle(port, "cpu", 0);
+       cpu_port = of_parse_phandle(port->dn, "cpu", 0);
        if (cpu_port) {
                cpu_port_reg = of_get_property(cpu_port, "reg", NULL);
                if (!cpu_port_reg)
@@ -571,8 +571,8 @@ static int dsa_ds_parse(struct dsa_switch_tree *dst,
struct dsa_switch *ds)

                if (dsa_port_is_cpu(port))
                        err = dsa_cpu_parse(port, index, dst, ds);
-               else if (dsa_is_normal_port(port))
-                       err = dsa_user_parse(port->dn, index,  ds);
+               else if (dsa_is_normal_port(ds, index))
+                       err = dsa_user_parse(port, index,  ds);

                        if (err)
                                return err;

-- 
Florian
