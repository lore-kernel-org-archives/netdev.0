From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH] Experimental new bonding driver mode=batman
Date: Tue, 19 May 2015 09:49:41 +0200
Message-ID: <20150519074941.GB17391@unicorn.suse.cz>
References: <555AD3A7.7050202@netscape.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick Simmons <linuxrocks123@netscape.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:41817 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753820AbbESHtn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2015 03:49:43 -0400
Content-Disposition: inline
In-Reply-To: <555AD3A7.7050202@netscape.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2015 at 02:09:43AM -0400, Patrick Simmons wrote:
> 
> I've written a new mode for the kernel bonding driver.  It's similar to
> the round-robin mode, but it keeps statistics on TCP resends so as to
> favor slave devices with more bandwidth when choosing where to send
> packets.  I've tested it on two laptops using WiFi/Ethernet and it seems
> to work okay, but it should be considered experimental.

A description of how is the mode supposed to work would be definitely
helpful.

Below are some comments from a quick look over the patch, I didn't think
too much about the logic of the operation.

> +struct batnode
> +{
> +     struct batnode* next_batnode;
> +     char slvname[IFNAMSIZ];
> +     unsigned long jiffiestamp;
> +     u32 tcp_seq_num;
> +     u16 port_id;
> +};
> +
> +struct slave_congestion_node
> +{
> +     struct slave_congestion_node* next_slave;
> +     char this_slave[IFNAMSIZ];
> +     u32 congestion_counter;
> +};

Referencing the slave by its name doesn't seem very efficient,
especially if you are going to do it in the xmit handler.

> +#define BATTABLE_SIZE 256
> +static struct batnode battable[BATTABLE_SIZE];
> +static struct slave_congestion_node* slavelist_head_ptr = NULL;

Why one global list rather than one list per bond? And why do you need
your own list in addition to already existing slave structures?

> +static struct slave_congestion_node* get_slave_congestion_node(char* slvname)
> +{
> +     //printk("In get_slave_congestion_node: 0x%zx\n",the_slave);
> +     struct slave_congestion_node* cur_slave = slavelist_head_ptr;
> +     while(cur_slave)
> +     {
> +          if(strcmp(cur_slave->this_slave,slvname)==0)
> +          {
> +               //printk("Found a match: 0x%zx\n",cur_slave);
> +               return cur_slave;
> +          }
> +
> +          if(!cur_slave->next_slave)
> +               break;
> +          cur_slave = cur_slave->next_slave;
> +     }     
> +
> +     //Create new slave node
> +     if(!cur_slave) //special case head
> +     {
> +          cur_slave = (struct slave_congestion_node*)(kmalloc(sizeof(struct slave_congestion_node),GFP_ATOMIC));
> +          slavelist_head_ptr = cur_slave;
> +     }
> +     else
> +     {
> +          cur_slave->next_slave = (struct slave_congestion_node*)(kmalloc(sizeof(struct slave_congestion_node),GFP_ATOMIC));
> +          cur_slave = cur_slave->next_slave;
> +     }

You don't handle kmalloc() failure.

> +
> +     //Initialize new slave node
> +     cur_slave->next_slave = NULL;
> +     strlcpy(cur_slave->this_slave,slvname,IFNAMSIZ);
> +     cur_slave->congestion_counter = 1;
> +     
> +     //printk("Created new congestion node: 0x%zx\n",cur_slave);
> +     return cur_slave;
> +}
> +
> +static void slave_congestion_increment(char* the_slave)
> +{
> +     get_slave_congestion_node(the_slave)->congestion_counter++;
> +}
> +
> +static void slave_congestion_decrement(char* the_slave)
> +{
> +     get_slave_congestion_node(the_slave)->congestion_counter--;
> +}

Should these three really be in a header file?

> +static DEFINE_SPINLOCK(batlock);

A lot of effort has been done recently to get rid of per-bond spinlocks.
Adding a global one kind of goes against this work.

> @@ -1082,6 +1088,69 @@ static bool bond_should_deliver_exact_ma
>  	return false;
>  }
>  
> +static void batman_normalize_congestion(struct bonding* bond, int* congestion)
> +{
> +     static long unsigned int jiffiestamp = 0;
> +     long unsigned int jiffie_temp = jiffies;
> +     struct slave* slave;
> +     struct list_head* i;
> +     if(jiffie_temp!=jiffiestamp && jiffie_temp%1000==0) //every thousand packets, normalize congestion

Looks more like every 1000 jiffies, not packets. And what if this
function doesn't get called in that one jiffy when jiffies is a multiple
of 1000? (Similar problem later in bond_xmit_batman().)

> +          printk(KERN_DEBUG "batman: congestion normalization has occurred.\n");

Use pr_debug() or netdev_dbg().

> +static int batman_timer_invoke(void* bond_)
> +{
> +     struct bonding* bond = (struct bonding*)(bond_);
> +     struct slave* slave;
> +     struct list_head* i;
> +
> +     while(!kthread_should_stop())
> +     {
> +          unsigned long batflags;
> +          long unsigned int jiffiestamp = jiffies;
> +          
> +          msleep(10*1000);
> +          rcu_read_lock();
> +          spin_lock_irqsave(&batlock,batflags);
> +          
> +          long unsigned int jiffie_temp = jiffies;
> +          if(!(jiffie_temp - jiffiestamp < 5 * HZ))
> +               bond_for_each_slave_rcu(bond,slave,i)
> +               {
> +                    struct slave_congestion_node* congest_current = get_slave_congestion_node(slave->dev->name);
> +                    if(congest_current->congestion_counter >= 2)
> +                         congest_current->congestion_counter/=2;
> +               }
> +
> +          spin_unlock_irqrestore(&batlock,batflags);
> +          rcu_read_unlock();
> +     }
> +}

This seems to only run something periodically, why do you need a (per
bond) kthread instead of a simple timer?

> @@ -1100,7 +1169,67 @@ static rx_handler_result_t bond_handle_f
>  	slave = bond_slave_get_rcu(skb->dev);
>  	bond = slave->bond;
>  
> -	recv_probe = ACCESS_ONCE(bond->recv_probe);
> +    //This seems as good a place as any to put this.
> +    if(skb->protocol == htons(ETH_P_IP))
> +    {
...
> +    }

I would suggest to handle TCP over IPv6 as well.

> @@ -4068,6 +4419,12 @@ void bond_setup(struct net_device *bond_
>  	bond_dev->hw_features &= ~(NETIF_F_ALL_CSUM & ~NETIF_F_HW_CSUM);
>  	bond_dev->hw_features |= NETIF_F_GSO_ENCAP_ALL;
>  	bond_dev->features |= bond_dev->hw_features;
> +
> +    if(bond_mode == BOND_MODE_BATMAN)
> +    {
> +         printk(KERN_INFO "%s: I'm Batman.\n",bond_dev->name);
> +         bond->battimer_task = kthread_run(batman_timer_invoke,bond,"%s_batman",bond_dev->name);
> +    }    
>  }
>  
>  /* Destroy a bonding device.

You only start the kthread in bond_setup() and stop it in
bond_destructor(). This doesn't handle the situation when the mode is
changed after the bond is created.

One general note: the patch breaks kernel coding style in a lot of
points. Running checkpatch.pl on it, I got

  total: 562 errors, 466 warnings, 5 checks, 585 lines checked

The script isn't perfect but this is too much.

                                                       Michal Kubecek
