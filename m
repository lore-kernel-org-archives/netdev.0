From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [patch] net: moxa: fix an error code
Date: Wed, 02 Mar 2016 12:36:05 +0100
Message-ID: <2743496.LmeGdM2Ipd@wuerfel>
References: <20160302101110.GI5533@mwanda> <7083740.CtlZQWRYiM@wuerfel> <20160302112129.GQ5273@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jonas Jensen <jonas.jensen@gmail.com>,
	Luis de Bethencourt <luis@debethencourt.com>,
	=?ISO-8859-1?Q?fran=E7ois?= romieu <romieu@fr.zoreil.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20160302112129.GQ5273@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 02 March 2016 14:21:29 Dan Carpenter wrote:
> On Wed, Mar 02, 2016 at 11:52:29AM +0100, Arnd Bergmann wrote:
> > Did you find more of these?
> > 
> > it doesn't matter much either way, but if you do multiple such patches,
> 
> One or two.  I already sent the fixes.  I think it was applied.
> 
> > I'd suggest using a single PTR_ERR_OR_ZERO() instead of IS_ERR()+PTR_ERR().
> > 
> > I have found a couple of drivers in which that leads to better object
> > code, and avoids a warning about a possibly uninitialized variable
> > when the function gets inlined into another one (which won't happen
> > for this driver).
> 
> Huh?  I sent one where I could have done that but I deliberately didn't
> because I wanted the uninitialized warning if I made a mistake.  It
> sounds like you're working around a GCC bug...

The uninitialized warning here is about a type mismatch preventing
gcc from noticing that two conditions are the same, I'm not sure
if this is a bug in gcc, or required by the C standard.

I don't think there is a way in which you would hide a correct
warning about an uninitialized warning.

Have a look at
https://git.kernel.org/cgit/linux/kernel/git/gfs2/linux-gfs2.git/commit/fs/gfs2?h=for-next&id=07cfdc3071432a07713e4d007c2811e0224490b0

in which get_leaf_nr() uses the IS_ERR()/PTR_ERR() combo to return
an error from a pointer, or return success when the pointer was set,
followed by a warning about the use of the pointer in another
function. My original patch avoided the warning by using IS_ERR_VALUE()
in the caller, but in retrospect, IS_ERR_OR_ZERO() would have been
a nicer solution:

@@ -783,12 +783,15 @@ static int get_leaf_nr(struct gfs2_inode *dip, u32 index,
                       u64 *leaf_out)
 {
        __be64 *hash;
+       int error;
 
        hash = gfs2_dir_get_hash_table(dip);
-       if (IS_ERR(hash))
-               return PTR_ERR(hash);
-       *leaf_out = be64_to_cpu(*(hash + index));
-       return 0;
+       error = PTR_ERR_OR_ZERO(hash);
+
+       if (!error)
+               *leaf_out = be64_to_cpu(*(hash + index));
+
+       return error;
 }

and I've used that elsewhere now when I ran into this kind of
false positive warning.

	Arnd
