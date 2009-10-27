From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] dcache: better name hash function
Date: Tue, 27 Oct 2009 16:08:22 -0700
Message-ID: <20091027160822.384dc109@nehalam>
References: <19864844.24581256620784317.JavaMail.root@tahiti.vyatta.com>
 <4AE68E23.20205@gmail.com>
 <4AE69829.9070207@gmail.com>
 <4AE6A16F.4020002@gmail.com>
 <20091027100736.5303f1ab@nehalam>
 <alpine.LFD.2.01.0910271017170.31845@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756250AbZJ0XI0@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.01.0910271017170.31845@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Oct 2009 10:32:44 -0700 (PDT)
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> 
> 
> On Tue, 27 Oct 2009, Stephen Hemminger wrote:
> > 
> > Rather than wasting space, or doing expensive, modulus; just folding
> > the higher bits back with XOR redistributes the bits better.
> 
> Please don't make up any new hash functions without having a better input 
> set than the one you seem to use.
> 
> The 'fnv' function I can believe in, because the whole "multiply by big 
> prime number" thing to spread out the bits is a very traditional model. 
> But making up a new hash function based on essentially consecutive names 
> is absolutely the wrong thing to do. You need a much better corpus of path 
> component names for testing.
> 
> > The following seems to give best results (combination of 16bit trick
> > and string17).
> 
> .. and these kinds of games are likely to work badly on some 
> architectures. Don't use 16-bit values, and don't use 'get_unaligned()'. 
> Both tend to work fine on x86, but likely suck on some other 
> architectures.
> 
> Also remember that the critical hash function needs to check for '/' and 
> '\0' while at it, which is one reason why it does things byte-at-a-time. 
> If you try to be smart, you'd need to be smart about the end condition 
> too.
> 
> The loop to optimize is _not_ based on 'name+len', it is this code:
> 
>                 this.name = name;
>                 c = *(const unsigned char *)name;
> 
>                 hash = init_name_hash();
>                 do {
>                         name++;
>                         hash = partial_name_hash(c, hash);
>                         c = *(const unsigned char *)name;
>                 } while (c && (c != '/'));
>                 this.len = name - (const char *) this.name;
>                 this.hash = end_name_hash(hash);
> 
> (which depends on us having already removed all slashed at the head, and 
> knowing that the string is not zero-sized)
> 
> So doing things multiple bytes at a time is certainly still possible, but 
> you would always have to find the slashes/NUL's in there first. Doing that 
> efficiently and portably is not trivial - especially since a lot of 
> critical path components are short.
> 
> (Remember: there may be just a few 'bin' directory names, but if you do 
> performance analysis, 'bin' as a path component is probably hashed a lot 
> more than 'five_slutty_bimbos_and_a_donkey.jpg'. So the relative weighting 
> of importance of the filename should probably include the frequency it 
> shows up in pathname lookup)
> 
> 		Linus


Going back to basics. Run tests across different input sets.
Dropping off the slow ones like crc, md5, ...
Not using jhash because it doesn't have good character at a time
interface.

Also, the folding algorithm used matters. Since the kernel
already uses hash_long() to fold back to N bits, all the
tests were rerun with that.

Test run across names in /usr
Algorithm             Time       Ratio       Max   StdDev
kr_hash              2.481275     1.21      4363 358.98
string10             2.834562     1.15      4168 303.66
fnv32                2.887600     1.18      4317 332.38
string_hash31        3.655745     1.16      4258 314.33
string_hash17        3.816443     1.16      4177 311.28
djb2                 3.883914     1.18      4269 331.75
full_name_hash       4.067633     1.16      4282 312.29
pjw                  6.517316     1.17      4184 316.69
sdbm                 6.945385     1.17      4447 324.32
elf                  7.402180     1.17      4184 316.69


And in /home (mail directories and git)
Algorithm             Time       Ratio       Max   StdDev
kr_hash              2.765015     1.44      7175 701.99
string10             3.136947     1.19      7092 469.73
fnv32                3.162626     1.19      6986 458.48
string_hash31        3.832031     1.19      7053 463.29
string_hash17        4.136220     1.19      7023 469.30
djb2                 4.241706     1.23      7537 512.02
full_name_hash       4.437741     1.19      7000 467.19
pjw                  6.758093     1.20      6970 476.03
sdbm                 7.239758     1.22      7526 494.32
elf                  7.446356     1.20      6970 476.03


And with names like pppXXX
Algorithm             Time       Ratio       Max   StdDev
kr_hash              0.849656     9.26      5520 1121.79
fnv32                1.004682     1.01       453  23.29
string10             1.004729     1.00       395   2.08
string_hash31        1.108335     1.00       409   5.14
string_hash17        1.231257     1.00       410   8.10
djb2                 1.238314     1.01       435  29.88
full_name_hash       1.320822     1.00       422  11.07
elf                  1.994794     1.15       716 151.19
pjw                  2.063958     1.15       716 151.19
sdbm                 2.070033     1.00       408   8.11

* The new test has big table so more cache effects.
* Existing full_name_hash distributes okay if folded correctly.
* fnv32 and string10 are slightly faster

More data (on /usr) from older slower machines:

IA-64
Algorithm             Time       Ratio       Max   StdDev
kr_hash              1.676064     1.17       664  63.81
string_hash17        1.773553     1.12       616  54.40
djb2                 2.103359     1.12       598  54.71
string10             2.103959     1.13       698  56.80
string_hash31        2.108254     1.13       602  55.51
full_name_hash       3.237209     1.13       614  56.74
sdbm                 3.279243     1.12       611  54.78
pjw                  3.314135     1.13       639  56.74
elf                  3.821029     1.13       639  56.74
fnv32                5.619829     1.16       865  62.51

Slow ULV 1Ghz laptop:
Algorithm             Time       Ratio       Max   StdDev
kr_hash              5.754460     1.19      2017 194.64
string10             6.698358     1.15      1638 171.29
sdbm                 8.134431     1.15      1652 170.65
djb2                 8.231058     1.17      1659 184.44
string_hash31        8.447873     1.15      1633 172.13
fnv32                8.552569     1.18      2170 189.61
string_hash17        9.226992     1.16      1616 175.01
full_name_hash       10.555072     1.15      1703 170.45
pjw                  16.193485     1.17      1642 181.45
elf                  19.770414     1.17      1642 181.45
