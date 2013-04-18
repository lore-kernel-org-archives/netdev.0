From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [PATCH 26/28] proc: Supply a function to remove a proc entry by
 PDE [RFC]
Date: Thu, 18 Apr 2013 10:41:40 -0600
Message-ID: <CAErSpo6UrUWZt1zNq=kmkTk4F6g4uAOs8VPKepdfeuKKxb7pXQ@mail.gmail.com>
References: <20130416182550.27773.89310.stgit@warthog.procyon.org.uk> <20130416182734.27773.47452.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	alsa-devel@alsa-project.org,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
	netdev <netdev@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	openipmi-developer@lists.sourceforge.net
To: David Howells <dhowells@redhat.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <20130416182734.27773.47452.stgit@warthog.procyon.org.uk>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 16, 2013 at 12:27 PM, David Howells <dhowells@redhat.com> wrote:
> Supply a function (proc_remove()) to remove a proc entry (and any subtree
> rooted there) by proc_dir_entry pointer rather than by name and (optionally)
> root dir entry pointer.  This allows us to eliminate all remaining pde->name
> accesses outside of procfs.
>
> Signed-off-by: David Howells <dhowells@redhat.com>
> cc: linux-acpi@vger.kernel.org
> cc: openipmi-developer@lists.sourceforge.net
> cc: devicetree-discuss@lists.ozlabs.org
> cc: linux-pci@vger.kernel.org
> cc: netdev@vger.kernel.org
> cc: netfilter-devel@vger.kernel.org
> cc: alsa-devel@alsa-project.org
> ---
>
>  drivers/acpi/sbs.c                  |   21 ++++-----------------
>  drivers/char/ipmi/ipmi_msghandler.c |    2 +-
>  drivers/misc/sgi-gru/gruprocfs.c    |    2 +-
>  drivers/of/base.c                   |   11 +----------
>  drivers/pci/proc.c                  |   12 +++---------

For the drivers/pci part:

Acked-by: Bjorn Helgaas <bhelgaas@google.com>

I assume you'll merge this via something other than my tree.

>  fs/proc/generic.c                   |    7 +++++++
>  fs/proc/vmcore.c                    |    2 +-
>  include/linux/proc_fs.h             |    2 ++
>  kernel/irq/proc.c                   |    6 +-----
>  net/8021q/vlanproc.c                |    9 ++-------
>  net/core/pktgen.c                   |    6 ++----
>  net/ipv4/netfilter/ipt_CLUSTERIP.c  |    4 ++--
>  net/ipv6/proc.c                     |    3 +--
>  net/netfilter/xt_hashlimit.c        |    4 ++--
>  sound/core/info.c                   |   19 +++++--------------
>  15 files changed, 35 insertions(+), 75 deletions(-)
>
> diff --git a/drivers/acpi/sbs.c b/drivers/acpi/sbs.c
> index a296e08..b6241ee 100644
> --- a/drivers/acpi/sbs.c
> +++ b/drivers/acpi/sbs.c
> @@ -521,19 +521,6 @@ acpi_sbs_add_fs(struct proc_dir_entry **dir,
>         return 0;
>  }
>
> -static void
> -acpi_sbs_remove_fs(struct proc_dir_entry **dir,
> -                          struct proc_dir_entry *parent_dir)
> -{
> -       if (*dir) {
> -               remove_proc_entry(ACPI_SBS_FILE_INFO, *dir);
> -               remove_proc_entry(ACPI_SBS_FILE_STATE, *dir);
> -               remove_proc_entry(ACPI_SBS_FILE_ALARM, *dir);
> -               remove_proc_entry((*dir)->name, parent_dir);
> -               *dir = NULL;
> -       }
> -}
> -
>  /* Smart Battery Interface */
>  static struct proc_dir_entry *acpi_battery_dir = NULL;
>
> @@ -836,8 +823,8 @@ static void acpi_battery_remove(struct acpi_sbs *sbs, int id)
>                 power_supply_unregister(&battery->bat);
>         }
>  #ifdef CONFIG_ACPI_PROCFS_POWER
> -       if (battery->proc_entry)
> -               acpi_sbs_remove_fs(&battery->proc_entry, acpi_battery_dir);
> +       proc_remove(battery->proc_entry);
> +       battery->proc_entry = NULL;
>  #endif
>  }
>
> @@ -873,8 +860,8 @@ static void acpi_charger_remove(struct acpi_sbs *sbs)
>         if (sbs->charger.dev)
>                 power_supply_unregister(&sbs->charger);
>  #ifdef CONFIG_ACPI_PROCFS_POWER
> -       if (sbs->charger_entry)
> -               acpi_sbs_remove_fs(&sbs->charger_entry, acpi_ac_dir);
> +       proc_remove(sbs->charger_entry);
> +       sbs->charger_entry = NULL;
>  #endif
>  }
>
> diff --git a/drivers/char/ipmi/ipmi_msghandler.c b/drivers/char/ipmi/ipmi_msghandler.c
> index 1420bbb..4d439d2 100644
> --- a/drivers/char/ipmi/ipmi_msghandler.c
> +++ b/drivers/char/ipmi/ipmi_msghandler.c
> @@ -4541,7 +4541,7 @@ static void __exit cleanup_ipmi(void)
>         del_timer_sync(&ipmi_timer);
>
>  #ifdef CONFIG_PROC_FS
> -       remove_proc_entry(proc_ipmi_root->name, NULL);
> +       proc_remove(proc_ipmi_root);
>  #endif /* CONFIG_PROC_FS */
>
>         driver_unregister(&ipmidriver.driver);
> diff --git a/drivers/misc/sgi-gru/gruprocfs.c b/drivers/misc/sgi-gru/gruprocfs.c
> index 950dbe9..797d796 100644
> --- a/drivers/misc/sgi-gru/gruprocfs.c
> +++ b/drivers/misc/sgi-gru/gruprocfs.c
> @@ -355,7 +355,7 @@ static void delete_proc_files(void)
>                 for (p = proc_files; p->name; p++)
>                         if (p->entry)
>                                 remove_proc_entry(p->name, proc_gru);
> -               remove_proc_entry("gru", proc_gru->parent);
> +               proc_remove(proc_gru);
>         }
>  }
>
> diff --git a/drivers/of/base.c b/drivers/of/base.c
> index 321d3ef..9c70436 100644
> --- a/drivers/of/base.c
> +++ b/drivers/of/base.c
> @@ -1452,16 +1452,7 @@ int of_attach_node(struct device_node *np)
>  #ifdef CONFIG_PROC_DEVICETREE
>  static void of_remove_proc_dt_entry(struct device_node *dn)
>  {
> -       struct device_node *parent = dn->parent;
> -       struct property *prop = dn->properties;
> -
> -       while (prop) {
> -               remove_proc_entry(prop->name, dn->pde);
> -               prop = prop->next;
> -       }
> -
> -       if (dn->pde)
> -               remove_proc_entry(dn->pde->name, parent->pde);
> +       proc_remove(dn->pde);
>  }
>  #else
>  static void of_remove_proc_dt_entry(struct device_node *dn)
> diff --git a/drivers/pci/proc.c b/drivers/pci/proc.c
> index 7cde7c1..0812608 100644
> --- a/drivers/pci/proc.c
> +++ b/drivers/pci/proc.c
> @@ -427,20 +427,14 @@ int pci_proc_attach_device(struct pci_dev *dev)
>
>  int pci_proc_detach_device(struct pci_dev *dev)
>  {
> -       struct proc_dir_entry *e;
> -
> -       if ((e = dev->procent)) {
> -               remove_proc_entry(e->name, dev->bus->procdir);
> -               dev->procent = NULL;
> -       }
> +       proc_remove(dev->procent);
> +       dev->procent = NULL;
>         return 0;
>  }
>
>  int pci_proc_detach_bus(struct pci_bus* bus)
>  {
> -       struct proc_dir_entry *de = bus->procdir;
> -       if (de)
> -               remove_proc_entry(de->name, proc_bus_pci_dir);
> +       proc_remove(bus->procdir);
>         return 0;
>  }
>
> diff --git a/fs/proc/generic.c b/fs/proc/generic.c
> index 2c6d6be..4b48033 100644
> --- a/fs/proc/generic.c
> +++ b/fs/proc/generic.c
> @@ -630,3 +630,10 @@ const char *get_proc_name(const struct proc_dir_entry *de)
>         return de->name;
>  }
>  EXPORT_SYMBOL_GPL(get_proc_name);
> +
> +void proc_remove(struct proc_dir_entry *de)
> +{
> +       if (de)
> +               remove_proc_subtree(de->name, de->parent);
> +}
> +EXPORT_SYMBOL(proc_remove);
> diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
> index 38edddc..17f7e08 100644
> --- a/fs/proc/vmcore.c
> +++ b/fs/proc/vmcore.c
> @@ -699,7 +699,7 @@ void vmcore_cleanup(void)
>         struct list_head *pos, *next;
>
>         if (proc_vmcore) {
> -               remove_proc_entry(proc_vmcore->name, proc_vmcore->parent);
> +               proc_remove(proc_vmcore);
>                 proc_vmcore = NULL;
>         }
>
> diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
> index 7abc72a..b8949b1 100644
> --- a/include/linux/proc_fs.h
> +++ b/include/linux/proc_fs.h
> @@ -67,6 +67,7 @@ struct proc_dir_entry *proc_create_data(const char *name, umode_t mode,
>                                 struct proc_dir_entry *parent,
>                                 const struct file_operations *proc_fops,
>                                 void *data);
> +extern void proc_remove(struct proc_dir_entry *);
>  extern void remove_proc_entry(const char *name, struct proc_dir_entry *parent);
>  extern int remove_proc_subtree(const char *name, struct proc_dir_entry *parent);
>
> @@ -103,6 +104,7 @@ static inline struct proc_dir_entry *proc_create_data(const char *name,
>  {
>         return NULL;
>  }
> +static inline void proc_remove(struct proc_dir_entry *de) {}
>  #define remove_proc_entry(name, parent) do {} while (0)
>  #define remove_proc_subtree(name, parent) do {} while (0)
>
> diff --git a/kernel/irq/proc.c b/kernel/irq/proc.c
> index d59ae37..19ed5c4 100644
> --- a/kernel/irq/proc.c
> +++ b/kernel/irq/proc.c
> @@ -366,11 +366,7 @@ void unregister_irq_proc(unsigned int irq, struct irq_desc *desc)
>
>  void unregister_handler_proc(unsigned int irq, struct irqaction *action)
>  {
> -       if (action->dir) {
> -               struct irq_desc *desc = irq_to_desc(irq);
> -
> -               remove_proc_entry(action->dir->name, desc->dir);
> -       }
> +       proc_remove(action->dir);
>  }
>
>  static void register_default_affinity_proc(void)
> diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
> index 959ddbb..1d0e8921 100644
> --- a/net/8021q/vlanproc.c
> +++ b/net/8021q/vlanproc.c
> @@ -184,14 +184,9 @@ int vlan_proc_add_dev(struct net_device *vlandev)
>   */
>  int vlan_proc_rem_dev(struct net_device *vlandev)
>  {
> -       struct vlan_net *vn = net_generic(dev_net(vlandev), vlan_net_id);
> -
>         /** NOTE:  This will consume the memory pointed to by dent, it seems. */
> -       if (vlan_dev_priv(vlandev)->dent) {
> -               remove_proc_entry(vlan_dev_priv(vlandev)->dent->name,
> -                                 vn->proc_vlan_dir);
> -               vlan_dev_priv(vlandev)->dent = NULL;
> -       }
> +       proc_remove(vlan_dev_priv(vlandev)->dent);
> +       vlan_dev_priv(vlandev)->dent = NULL;
>         return 0;
>  }
>
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index f6af4fe..6c41e97 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -1904,7 +1904,7 @@ static void pktgen_change_name(const struct pktgen_net *pn, struct net_device *d
>                         if (pkt_dev->odev != dev)
>                                 continue;
>
> -                       remove_proc_entry(pkt_dev->entry->name, pn->proc_dir);
> +                       proc_remove(pkt_dev->entry);
>
>                         pkt_dev->entry = proc_create_data(dev->name, 0600,
>                                                           pn->proc_dir,
> @@ -3576,8 +3576,6 @@ static void _rem_dev_from_if_list(struct pktgen_thread *t,
>  static int pktgen_remove_device(struct pktgen_thread *t,
>                                 struct pktgen_dev *pkt_dev)
>  {
> -       struct pktgen_net *pn = t->net;
> -
>         pr_debug("remove_device pkt_dev=%p\n", pkt_dev);
>
>         if (pkt_dev->running) {
> @@ -3597,7 +3595,7 @@ static int pktgen_remove_device(struct pktgen_thread *t,
>         _rem_dev_from_if_list(t, pkt_dev);
>
>         if (pkt_dev->entry)
> -               remove_proc_entry(pkt_dev->entry->name, pn->proc_dir);
> +               proc_remove(pkt_dev->entry);
>
>  #ifdef CONFIG_XFRM
>         free_SAs(pkt_dev);
> diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
> index e4738fe..0b732ef 100644
> --- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
> +++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
> @@ -105,7 +105,7 @@ clusterip_config_entry_put(struct clusterip_config *c)
>                  * functions are also incrementing the refcount on their own,
>                  * so it's safe to remove the entry even if it's in use. */
>  #ifdef CONFIG_PROC_FS
> -               remove_proc_entry(c->pde->name, c->pde->parent);
> +               proc_remove(c->pde);
>  #endif
>                 return;
>         }
> @@ -736,7 +736,7 @@ static void __exit clusterip_tg_exit(void)
>  {
>         pr_info("ClusterIP Version %s unloading\n", CLUSTERIP_VERSION);
>  #ifdef CONFIG_PROC_FS
> -       remove_proc_entry(clusterip_procdir->name, clusterip_procdir->parent);
> +       proc_remove(clusterip_procdir);
>  #endif
>         nf_unregister_hook(&cip_arp_ops);
>         xt_unregister_target(&clusterip_tg_reg);
> diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
> index 7ea6e18..537d9ee 100644
> --- a/net/ipv6/proc.c
> +++ b/net/ipv6/proc.c
> @@ -287,8 +287,7 @@ int snmp6_unregister_dev(struct inet6_dev *idev)
>                 return -ENOENT;
>         if (!idev->stats.proc_dir_entry)
>                 return -EINVAL;
> -       remove_proc_entry(idev->stats.proc_dir_entry->name,
> -                         net->mib.proc_net_devsnmp6);
> +       proc_remove(idev->stats.proc_dir_entry);
>         idev->stats.proc_dir_entry = NULL;
>         return 0;
>  }
> diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
> index d2fd53b..40002ef 100644
> --- a/net/netfilter/xt_hashlimit.c
> +++ b/net/netfilter/xt_hashlimit.c
> @@ -330,7 +330,7 @@ static void htable_destroy(struct xt_hashlimit_htable *hinfo)
>                 parent = hashlimit_net->ip6t_hashlimit;
>
>         if(parent != NULL)
> -               remove_proc_entry(hinfo->pde->name, parent);
> +               proc_remove(hinfo->pde);
>
>         htable_selective_cleanup(hinfo, select_all);
>         vfree(hinfo);
> @@ -887,7 +887,7 @@ static void __net_exit hashlimit_proc_net_exit(struct net *net)
>                 pde = hashlimit_net->ip6t_hashlimit;
>
>         hlist_for_each_entry(hinfo, &hashlimit_net->htables, node)
> -               remove_proc_entry(hinfo->pde->name, pde);
> +               proc_remove(hinfo->pde);
>
>         hashlimit_net->ipt_hashlimit = NULL;
>         hashlimit_net->ip6t_hashlimit = NULL;
> diff --git a/sound/core/info.c b/sound/core/info.c
> index c7f41c3..3c9bd6b 100644
> --- a/sound/core/info.c
> +++ b/sound/core/info.c
> @@ -153,13 +153,6 @@ EXPORT_SYMBOL(snd_seq_root);
>  struct snd_info_entry *snd_oss_root;
>  #endif
>
> -static void snd_remove_proc_entry(struct proc_dir_entry *parent,
> -                                 struct proc_dir_entry *de)
> -{
> -       if (de)
> -               remove_proc_entry(de->name, parent);
> -}
> -
>  static loff_t snd_info_entry_llseek(struct file *file, loff_t offset, int orig)
>  {
>         struct snd_info_private_data *data;
> @@ -580,7 +573,7 @@ int __exit snd_info_done(void)
>  #ifdef CONFIG_SND_OSSEMUL
>                 snd_info_free_entry(snd_oss_root);
>  #endif
> -               snd_remove_proc_entry(NULL, snd_proc_root);
> +               proc_remove(snd_proc_root);
>         }
>         return 0;
>  }
> @@ -642,7 +635,7 @@ void snd_info_card_id_change(struct snd_card *card)
>  {
>         mutex_lock(&info_mutex);
>         if (card->proc_root_link) {
> -               snd_remove_proc_entry(snd_proc_root, card->proc_root_link);
> +               proc_remove(card->proc_root_link);
>                 card->proc_root_link = NULL;
>         }
>         if (strcmp(card->id, card->proc_root->name))
> @@ -661,10 +654,8 @@ void snd_info_card_disconnect(struct snd_card *card)
>         if (!card)
>                 return;
>         mutex_lock(&info_mutex);
> -       if (card->proc_root_link) {
> -               snd_remove_proc_entry(snd_proc_root, card->proc_root_link);
> -               card->proc_root_link = NULL;
> -       }
> +       proc_remove(card->proc_root_link);
> +       card->proc_root_link = NULL;
>         if (card->proc_root)
>                 snd_info_disconnect(card->proc_root);
>         mutex_unlock(&info_mutex);
> @@ -856,7 +847,7 @@ static void snd_info_disconnect(struct snd_info_entry *entry)
>         list_del_init(&entry->list);
>         root = entry->parent == NULL ? snd_proc_root : entry->parent->p;
>         snd_BUG_ON(!root);
> -       snd_remove_proc_entry(root, entry->p);
> +       proc_remove(entry->p);
>         entry->p = NULL;
>  }
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
