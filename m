From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next v2 1/2] libbpf: parse maps sections of varying
 size
Date: Tue, 3 Oct 2017 16:03:48 +0200
Message-ID: <20171003160348.1d84548d@redhat.com>
References: <20171002164129.47986-1-kraigatgoog@gmail.com>
        <20171002164129.47986-2-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Chonggang Li <chonggangli@google.com>, netdev@vger.kernel.org,
        brouer@redhat.com, Eric Leblond <eric@regit.org>,
        "Wangnan (F)" <wangnan0@huawei.com>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58624 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751267AbdJCODz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Oct 2017 10:03:55 -0400
In-Reply-To: <20171002164129.47986-2-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



First of all, thank you Craig for working on this.  As Alexei says, we
need to improve tools/lib/bpf/libbpf and move towards converting users
of bpf_load.c to this lib instead.

Comments inlined below.

On Mon,  2 Oct 2017 12:41:28 -0400 Craig Gallek <kraigatgoog@gmail.com> wrote:

> From: Craig Gallek <kraig@google.com>
> 
> This library previously assumed a fixed-size map options structure.
> Any new options were ignored.  In order to allow the options structure
> to grow and to support parsing older programs, this patch updates
> the maps section parsing to handle varying sizes.
> 
> Object files with maps sections smaller than expected will have the new
> fields initialized to zero.  Object files which have larger than expected
> maps sections will be rejected unless all of the unrecognized data is zero.
> 
> This change still assumes that each map definition in the maps section
> is the same size.
> 
> Signed-off-by: Craig Gallek <kraig@google.com>
> ---
>  tools/lib/bpf/libbpf.c | 54 ++++++++++++++++++++++++++++++++++++++++++--------
>  1 file changed, 46 insertions(+), 8 deletions(-)
> 
> diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
> index 4f402dcdf372..28b300868ad7 100644
> --- a/tools/lib/bpf/libbpf.c
> +++ b/tools/lib/bpf/libbpf.c
> @@ -580,7 +580,7 @@ bpf_object__init_kversion(struct bpf_object *obj,
>  }
>  
>  static int
> -bpf_object__validate_maps(struct bpf_object *obj)
> +bpf_object__validate_maps(struct bpf_object *obj, int map_def_sz)
>  {
>  	int i;
>  
> @@ -595,9 +595,11 @@ bpf_object__validate_maps(struct bpf_object *obj)
>  		const struct bpf_map *a = &obj->maps[i - 1];
>  		const struct bpf_map *b = &obj->maps[i];
>  
> -		if (b->offset - a->offset < sizeof(struct bpf_map_def)) {
> -			pr_warning("corrupted map section in %s: map \"%s\" too small\n",
> -				   obj->path, a->name);
> +		if (b->offset - a->offset < map_def_sz) {
> +			pr_warning("corrupted map section in %s: map \"%s\" too small "
> +				   "(%zd vs %d)\n",
> +				   obj->path, a->name, b->offset - a->offset,
> +				   map_def_sz);
>  			return -EINVAL;
>  		}
>  	}
> @@ -615,7 +617,7 @@ static int compare_bpf_map(const void *_a, const void *_b)
>  static int
>  bpf_object__init_maps(struct bpf_object *obj)
>  {
> -	int i, map_idx, nr_maps = 0;
> +	int i, map_idx, map_def_sz, nr_maps = 0;
>  	Elf_Scn *scn;
>  	Elf_Data *data;
>  	Elf_Data *symbols = obj->efile.symbols;
> @@ -658,6 +660,15 @@ bpf_object__init_maps(struct bpf_object *obj)
>  	if (!nr_maps)
>  		return 0;
>  
> +	/* Assume equally sized map definitions */
> +	map_def_sz = data->d_size / nr_maps;
> +	if (!data->d_size || (data->d_size % nr_maps) != 0) {
> +		pr_warning("unable to determine map definition size "
> +			   "section %s, %d maps in %zd bytes\n",
> +			   obj->path, nr_maps, data->d_size);
> +		return -EINVAL;
> +	}
> +
>  	obj->maps = calloc(nr_maps, sizeof(obj->maps[0]));
>  	if (!obj->maps) {
>  		pr_warning("alloc maps for object failed\n");
> @@ -690,7 +701,7 @@ bpf_object__init_maps(struct bpf_object *obj)
>  				      obj->efile.strtabidx,
>  				      sym.st_name);
>  		obj->maps[map_idx].offset = sym.st_value;
> -		if (sym.st_value + sizeof(struct bpf_map_def) > data->d_size) {
> +		if (sym.st_value + map_def_sz > data->d_size) {
>  			pr_warning("corrupted maps section in %s: last map \"%s\" too small\n",
>  				   obj->path, map_name);
>  			return -EINVAL;
> @@ -704,12 +715,39 @@ bpf_object__init_maps(struct bpf_object *obj)
>  		pr_debug("map %d is \"%s\"\n", map_idx,
>  			 obj->maps[map_idx].name);
>  		def = (struct bpf_map_def *)(data->d_buf + sym.st_value);
> -		obj->maps[map_idx].def = *def;
> +		/*
> +		 * If the definition of the map in the object file fits in
> +		 * bpf_map_def, copy it.  Any extra fields in our version
> +		 * of bpf_map_def will default to zero as a result of the
> +		 * calloc above.
> +		 */
> +		if (map_def_sz <= sizeof(struct bpf_map_def)) {
> +			memcpy(&obj->maps[map_idx].def, def, map_def_sz);
> +		} else {
> +			/*
> +			 * Here the map structure being read is bigger than what
> +			 * we expect, truncate if the excess bits are all zero.
> +			 * If they are not zero, reject this map as
> +			 * incompatible.
> +			 */
> +			char *b;
> +			for (b = ((char *)def) + sizeof(struct bpf_map_def);
> +			     b < ((char *)def) + map_def_sz; b++) {
> +				if (*b != 0) {
> +					pr_warning("maps section in %s: \"%s\" "
> +						   "has unrecognized, non-zero "
> +						   "options\n",
> +						   obj->path, map_name);
> +					return -EINVAL;
> +				}
> +			}
> +			obj->maps[map_idx].def = *def;

I'm not too happy/comfortable with this way of copying the memory of
"def" (the type-cased struct bpf_map_def).  I guess it works, and is
part of the C-standard(?).


> +		}
>  		map_idx++;
>  	}
>  
>  	qsort(obj->maps, obj->nr_maps, sizeof(obj->maps[0]), compare_bpf_map);
> -	return bpf_object__validate_maps(obj);
> +	return bpf_object__validate_maps(obj, map_def_sz);
>  }
>  
>  static int bpf_object__elf_collect(struct bpf_object *obj)

Besides above comment, I think the patch is correct, based on what I
did in commit 156450d9d964 ("samples/bpf: make bpf_load.c code
compatible with ELF maps section changes").

  https://git.kernel.org/torvalds/c/156450d9d964

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
