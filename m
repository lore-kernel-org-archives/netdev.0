From: Shawn Guo <shawn.guo-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Subject: Re: [PATCH v2 1/5] dt: add of_alias_scan and of_alias_get_id
Date: Fri, 15 Jul 2011 23:24:50 +0800
Message-ID: <20110715152449.GF1840@S2100-06.ap.freescale.net>
References: <1308938676-31121-1-git-send-email-shawn.guo@linaro.org>
	<1308938676-31121-2-git-send-email-shawn.guo@linaro.org>
	<20110715025320.GE2927@ponder.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110715025320.GE2927-e0URQFbLeQY2iJbIjFUEsiwD8/FfD2ys@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 14, 2011 at 08:53:20PM -0600, Grant Likely wrote:
> On Sat, Jun 25, 2011 at 02:04:32AM +0800, Shawn Guo wrote:
> > The patch adds function of_alias_scan to populate a global lookup
> > table with the properties of 'aliases' node and function
> > of_alias_get_id for drivers to find alias id from the lookup table.
> > 
> > Signed-off-by: Shawn Guo <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> > Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
> 
> Hey Shawn,
> 
> Comments below, but I've gone ahead and fixed them because I'm keen to
> get this patch merged.  I just wanted to let you know what I changed.
> I'll post the modified version so you can test it.
> 
Thanks for doing this.  It makes the wheel spin fast.  I respect
changes you made, and will give it a test once you post it.

Regards,
Shawn

> > ---
> >  drivers/of/base.c  |  181 ++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  drivers/of/fdt.c   |    6 ++
> >  include/linux/of.h |    7 ++
> >  3 files changed, 194 insertions(+), 0 deletions(-)
> > 
> > diff --git a/drivers/of/base.c b/drivers/of/base.c
> > index 632ebae..89efd10 100644
> > --- a/drivers/of/base.c
> > +++ b/drivers/of/base.c
> > @@ -17,14 +17,38 @@
> >   *      as published by the Free Software Foundation; either version
> >   *      2 of the License, or (at your option) any later version.
> >   */
> > +#include <linux/bootmem.h>
> > +#include <linux/ctype.h>
> >  #include <linux/module.h>
> >  #include <linux/of.h>
> >  #include <linux/spinlock.h>
> >  #include <linux/slab.h>
> >  #include <linux/proc_fs.h>
> >  
> > +/**
> > + * struct alias_prop - Alias property in 'aliases' node
> > + * @link:	List node to link the structure in aliases_lookup list
> > + * @alias:	Alias property name
> > + * @np:		Pointer to device_node that the alias stands for
> > + * @alias_id:	Alias id decoded from alias
> > + * @alias_stem:	Alias stem name decoded from alias
> > + *
> > + * The structure represents one alias property of 'aliases' node as
> > + * an entry in aliases_lookup list.
> > + */
> > +struct alias_prop {
> > +	struct list_head link;
> > +	const char *alias;
> > +	struct device_node *np;
> > +	int alias_id;
> > +	char alias_stem[0];
> > +};
> > +
> > +static LIST_HEAD(aliases_lookup);
> > +
> >  struct device_node *allnodes;
> >  struct device_node *of_chosen;
> > +struct device_node *of_aliases;
> >  
> >  /* use when traversing tree through the allnext, child, sibling,
> >   * or parent members of struct device_node.
> > @@ -922,3 +946,160 @@ out_unlock:
> >  }
> >  #endif /* defined(CONFIG_OF_DYNAMIC) */
> >  
> > +/*
> > + * of_alias_find_available_id - Find an available id for the given device_node
> 
> Nit: kerneldoc format is "/**" to start the comment, and function
> names should have '()' on it.
> 
> > + * @np:		Pointer to the given device_node
> > + * @stem:	Alias stem of the given device_node
> > + *
> > + * The function travels the lookup table to find an available id for the
> > + * given device_node with given alias stem.  It returns the id found.
> > + */
> > +static int of_alias_find_available_id(struct device_node *np, const char *stem)
> > +{
> > +	struct alias_prop *app;
> > +	int id = 0;
> > +
> > +	while (1) {
> > +		bool used = false;
> > +		list_for_each_entry(app, &aliases_lookup, link) {
> > +			if (!strcmp(app->alias_stem, stem) &&
> > +			    app->alias_id == id) {
> > +				used = true;
> > +				break;
> > +			}
> > +		}
> > +
> > +		if (used)
> > +			id++;
> > +		else
> > +			return id;
> > +	}
> > +}
> 
> I've simplified this somewhat to do the list_for_each_entry() only
> once, and to bump up the id to +1 the largest entry:
> 
> 	list_for_each_entry(app, &aliases_lookup, link)
> 		if ((strcmp(app->stem, stem) == 0) && id <= app->id)
> 			id = app->id + 1;
> 
> .... actually, after looking further, I've rolled this code into the
> of_alias_get_id() function.
> 
> > +
> > +/**
> > + * of_alias_lookup_add - Add alias into lookup table
> > + * @alias:	Alias name
> > + * @id:		Alias id
> > + * @stem:	Alias stem name
> > + * @np:		Pointer to device_node
> > + *
> > + * The function adds one alias into the lookup table and populate it
> > + * with the info passed in.  It returns 0 in sucess, or error code.
> > + */
> > +static int of_alias_lookup_add(char *alias, int id, const char *stem,
> > +			       struct device_node *np)
> > +{
> > +	struct alias_prop *app;
> > +	size_t sz = sizeof(*app) + strlen(stem) + 1;
> > +
> > +	app = kzalloc(sz, GFP_KERNEL);
> > +	if (!app) {
> > +		/*
> > +		 * It may fail due to being called by boot code,
> > +		 * so try alloc_bootmem before return error.
> > +		 */
> > +		app = alloc_bootmem(sz);
> > +		if (!app)
> > +			return -ENOMEM;
> > +	}
> 
> I'm not too fond of this since we *know* when this is going to be
> called from early boot.  So, instead, I've changed the code to use the
> already existing dt_alloc functions as an argument to of_alias_lookup_add().
> 
> Also, alloc_bootmem() doesn't work on all platforms.
> early_init_dt_alloc_memory_arch() needs to be used instead.
> 
> 
> > +
> > +	app->np = np;
> > +	app->alias = alias;
> > +	app->alias_id = id;
> > +	strcpy(app->alias_stem, stem);
> > +	list_add_tail(&app->link, &aliases_lookup);
> > +
> > +	return 0;
> > +}
> > +
> > +/**
> > + * of_alias_decode - Decode alias stem and id from alias name
> > + * @alias:	Alias name to be decoded
> > + * @stem:	Pointer used to return stem name
> > + *
> > + * The function decodes alias stem name and alias id from the given
> > + * alias name.  It returns stem name via parameter 'stem', and stem id
> > + * via the return value.  If no id is found in alias name, it returns 0
> > + * as the default.
> > + */
> > +static int of_alias_decode(char *alias, char *stem)
> > +{
> > +	int len = strlen(alias);
> > +	char *end = alias + len;
> > +
> > +	while (isdigit(*--end))
> > +		len--;
> 
> Need to protect against len < 0
> 
> > +
> > +	strncpy(stem, alias, len);
> > +	stem[len] = '\0';
> > +
> > +	return strlen(++end) ? simple_strtoul(end, NULL, 10) : 0;
> > +}
> > +
> > +/**
> > + * of_alias_scan - Scan all properties of 'aliases' node
> > + *
> > + * The function scans all the properties of 'aliases' node and populate
> > + * the the global lookup table with the properties.  It returns the
> > + * number of alias_prop found, or error code in error case.
> > + */
> > +int of_alias_scan(void)
> 
> Changed to '__init void of_aliases_scan(void)'.  There is no point in
> returning an error code since it is never checked, and there is no
> point in bailing on an error just in case it is a problem with only
> one alias.
> 
> > +{
> > +	struct property *pp;
> > +	int ret, num = 0;
> > +
> > +	if (!of_aliases)
> > +		return -ENODEV;
> > +
> > +	for_each_property(pp, of_aliases->properties) {
> > +		char stem[32];
> > +		int id = of_alias_decode(pp->name, stem);
> > +
> > +		/* Skip those we do not want to proceed */
> > +		if (!strcmp(pp->name, "name") ||
> > +		    !strcmp(pp->name, "phandle") ||
> > +		    !strcmp(pp->name, "linux,phandle"))
> > +			continue;
> > +
> > +		ret = of_alias_lookup_add(pp->name, id, stem,
> > +					  of_find_node_by_path(pp->value));
> > +		if (ret < 0)
> > +			return ret;
> > +		else
> > +			num++;
> > +	}
> > +
> > +	return num;
> > +}
> > +
> > +/**
> > + * of_alias_get_id - Get alias id for the given device_node
> > + * @np:		Pointer to the given device_node
> > + * @stem:	Alias stem of the given device_node
> > + *
> > + * The function travels the lookup table to get alias id for the given
> > + * device_node and alias stem.  It returns the alias id if find it.
> > + * If not, dynamically creates one in the lookup table and returns it,
> > + * or returns error code if fail to create.
> > + */
> > +int of_alias_get_id(struct device_node *np, const char *stem)
> > +{
> > +	struct alias_prop *app;
> > +	int id = -1;
> > +
> > +	list_for_each_entry(app, &aliases_lookup, link) {
> > +		if (np == app->np) {
> > +			id = app->alias_id;
> > +			break;
> > +		}
> > +	}
> > +
> > +	if (id == -1) {
> > +		id = of_alias_find_available_id(np, stem);
> > +		if (of_alias_lookup_add(NULL, id, stem, np) < 0)
> > +			return -ENODEV;
> > +	}
> > +
> > +	return id;
> > +}
> 
> This whole function needs to be protected by a mutex.
> 
> > +EXPORT_SYMBOL_GPL(of_alias_get_id);
> > diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
> > index 65200af..998dc63 100644
> > --- a/drivers/of/fdt.c
> > +++ b/drivers/of/fdt.c
> > @@ -711,6 +711,12 @@ void __init unflatten_device_tree(void)
> >  	of_chosen = of_find_node_by_path("/chosen");
> >  	if (of_chosen == NULL)
> >  		of_chosen = of_find_node_by_path("/chosen@0");
> > +
> > +	of_aliases = of_find_node_by_path("/aliases");
> > +	if (of_aliases == NULL)
> > +		of_aliases = of_find_node_by_path("/aliases@0");
> 
> I don't think the /aliases@0 variant is necessary.  I've dropped it.
> 
> g.
> 
> > +
> > +	of_alias_scan();
> >  }
> >  
> >  #endif /* CONFIG_OF_EARLY_FLATTREE */
> > diff --git a/include/linux/of.h b/include/linux/of.h
> > index bfc0ed1..c35cc47 100644
> > --- a/include/linux/of.h
> > +++ b/include/linux/of.h
> > @@ -68,6 +68,7 @@ struct device_node {
> >  /* Pointer for first entry in chain of all nodes. */
> >  extern struct device_node *allnodes;
> >  extern struct device_node *of_chosen;
> > +extern struct device_node *of_aliases;
> >  extern rwlock_t devtree_lock;
> >  
> >  static inline bool of_have_populated_dt(void)
> > @@ -201,6 +202,9 @@ extern int of_device_is_available(const struct device_node *device);
> >  extern const void *of_get_property(const struct device_node *node,
> >  				const char *name,
> >  				int *lenp);
> > +#define for_each_property(pp, properties) \
> > +	for (pp = properties; pp != NULL; pp = pp->next)
> > +
> >  extern int of_n_addr_cells(struct device_node *np);
> >  extern int of_n_size_cells(struct device_node *np);
> >  extern const struct of_device_id *of_match_node(
> > @@ -213,6 +217,9 @@ extern int of_parse_phandles_with_args(struct device_node *np,
> >  	const char *list_name, const char *cells_name, int index,
> >  	struct device_node **out_node, const void **out_args);
> >  
> > +extern int of_alias_scan(void);
> > +extern int of_alias_get_id(struct device_node *np, const char *stem);
> > +
> >  extern int of_machine_is_compatible(const char *compat);
> >  
> >  extern int prom_add_property(struct device_node* np, struct property* prop);
> > -- 
> > 1.7.4.1
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
