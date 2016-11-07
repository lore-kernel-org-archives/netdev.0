From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH 7/8] tools lib bpf: fix maps resolution
Date: Tue, 8 Nov 2016 02:23:58 +0800
Message-ID: <5820C6BE.9080300@huawei.com>
References: <20161016211834.11732-1-eric@regit.org>
 <20161016211834.11732-8-eric@regit.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Joe Stringer <joe@ovn.org>
To: Eric Leblond <eric@regit.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161016211834.11732-8-eric@regit.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

Are you still working in this patch set?

Now I know why maps section is not a simple array
from a patch set from Joe Stringer:

https://www.mail-archive.com/netdev@vger.kernel.org/msg135088.html

So I think this patch is really useful.

Are you going to resend the whole patch set? If not, let me collect
this patch 7/8 into my local code base and send to Arnaldo
with my other patches.

Thank you.

On 2016/10/17 5:18, Eric Leblond wrote:
> It is not correct to assimilate the elf data of the maps section
> to an array of map definition. In fact the sizes differ. The
> offset provided in the symbol section has to be used instead.
>
> This patch fixes a bug causing a elf with two maps not to load
> correctly.
>
> Signed-off-by: Eric Leblond <eric@regit.org>
> ---
>   tools/lib/bpf/libbpf.c | 50 +++++++++++++++++++++++++++++++++++---------------
>   1 file changed, 35 insertions(+), 15 deletions(-)
>
> diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
> index 1fe4532..f72628b 100644
> --- a/tools/lib/bpf/libbpf.c
> +++ b/tools/lib/bpf/libbpf.c
> @@ -186,6 +186,7 @@ struct bpf_program {
>   struct bpf_map {
>   	int fd;
>   	char *name;
> +	size_t offset;
>   	struct bpf_map_def def;
>   	void *priv;
>   	bpf_map_clear_priv_t clear_priv;
> @@ -529,13 +530,6 @@ bpf_object__init_maps(struct bpf_object *obj, void *data,
>   
>   	pr_debug("maps in %s: %zd bytes\n", obj->path, size);
>   
> -	obj->maps = calloc(nr_maps, sizeof(obj->maps[0]));
> -	if (!obj->maps) {
> -		pr_warning("alloc maps for object failed\n");
> -		return -ENOMEM;
> -	}
> -	obj->nr_maps = nr_maps;
> -
>   	for (i = 0; i < nr_maps; i++) {
>   		struct bpf_map_def *def = &obj->maps[i].def;
>   
> @@ -547,23 +541,42 @@ bpf_object__init_maps(struct bpf_object *obj, void *data,
>   		obj->maps[i].fd = -1;
>   
>   		/* Save map definition into obj->maps */
> -		*def = ((struct bpf_map_def *)data)[i];
> +		*def = *(struct bpf_map_def *)(data + obj->maps[i].offset);
>   	}
>   	return 0;
>   }
>   
>   static int
> -bpf_object__init_maps_name(struct bpf_object *obj)
> +bpf_object__init_maps_symbol(struct bpf_object *obj)
>   {
>   	int i;
> +	int nr_maps = 0;
>   	Elf_Data *symbols = obj->efile.symbols;
> +	size_t map_idx = 0;
>   
>   	if (!symbols || obj->efile.maps_shndx < 0)
>   		return -EINVAL;
>   
> +	/* get the number of maps */
> +	for (i = 0; i < symbols->d_size / sizeof(GElf_Sym); i++) {
> +		GElf_Sym sym;
> +
> +		if (!gelf_getsym(symbols, i, &sym))
> +			continue;
> +		if (sym.st_shndx != obj->efile.maps_shndx)
> +			continue;
> +		nr_maps++;
> +	}
> +
> +	obj->maps = calloc(nr_maps, sizeof(obj->maps[0]));
> +	if (!obj->maps) {
> +		pr_warning("alloc maps for object failed\n");
> +		return -ENOMEM;
> +	}
> +	obj->nr_maps = nr_maps;
> +
>   	for (i = 0; i < symbols->d_size / sizeof(GElf_Sym); i++) {
>   		GElf_Sym sym;
> -		size_t map_idx;
>   		const char *map_name;
>   
>   		if (!gelf_getsym(symbols, i, &sym))
> @@ -574,12 +587,12 @@ bpf_object__init_maps_name(struct bpf_object *obj)
>   		map_name = elf_strptr(obj->efile.elf,
>   				      obj->efile.strtabidx,
>   				      sym.st_name);
> -		map_idx = sym.st_value / sizeof(struct bpf_map_def);
>   		if (map_idx >= obj->nr_maps) {
>   			pr_warning("index of map \"%s\" is buggy: %zu > %zu\n",
>   				   map_name, map_idx, obj->nr_maps);
>   			continue;
>   		}
> +		obj->maps[map_idx].offset = sym.st_value;
>   		obj->maps[map_idx].name = strdup(map_name);
>   		if (!obj->maps[map_idx].name) {
>   			pr_warning("failed to alloc map name\n");
> @@ -587,6 +600,7 @@ bpf_object__init_maps_name(struct bpf_object *obj)
>   		}
>   		pr_debug("map %zu is \"%s\"\n", map_idx,
>   			 obj->maps[map_idx].name);
> +		map_idx++;
>   	}
>   	return 0;
>   }
> @@ -647,8 +661,6 @@ static int bpf_object__elf_collect(struct bpf_object *obj)
>   							data->d_buf,
>   							data->d_size);
>   		else if (strcmp(name, "maps") == 0) {
> -			err = bpf_object__init_maps(obj, data->d_buf,
> -						    data->d_size);
>   			obj->efile.maps_shndx = idx;
>   		} else if (sh.sh_type == SHT_SYMTAB) {
>   			if (obj->efile.symbols) {
> @@ -698,8 +710,16 @@ static int bpf_object__elf_collect(struct bpf_object *obj)
>   		pr_warning("Corrupted ELF file: index of strtab invalid\n");
>   		return LIBBPF_ERRNO__FORMAT;
>   	}
> -	if (obj->efile.maps_shndx >= 0)
> -		err = bpf_object__init_maps_name(obj);
> +	if (obj->efile.maps_shndx >= 0) {
> +		Elf_Data *data;
> +		err = bpf_object__init_maps_symbol(obj);
> +		if (err)
> +			goto out;
> +
> +		scn = elf_getscn(elf, obj->efile.maps_shndx);
> +		data = elf_getdata(scn, 0);
> +		err = bpf_object__init_maps(obj, data->d_buf, data->d_size);
> +	}
>   out:
>   	return err;
>   }
