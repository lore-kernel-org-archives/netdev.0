From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 56/77] net/core/filter.c:2475: undefined reference
 to `__dev_map_flush'
Date: Tue, 18 Jul 2017 07:43:30 +0800
Message-ID: <201707180727.AVLbjxqL%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="r5Pyd7+fXNt84Ff3"
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:24245 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751427AbdGQXnf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Jul 2017 19:43:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   24251c264798ac5a72667245c2650676d7ac2108
commit: 11393cc9b9be2a1f61559e6fb9c27bc8fa20b1ff [56/77] xdp: Add batching support to redirect map
config: m32r-opsput_defconfig (attached as .config)
compiler: m32r-linux-gcc (GCC) 6.2.0
reproduce:
        wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 11393cc9b9be2a1f61559e6fb9c27bc8fa20b1ff
        # save the attached .config to linux build tree
        make.cross ARCH=m32r 

All errors (new ones prefixed by >>):

   net/core/filter.o: In function `xdp_do_flush_map':
>> net/core/filter.c:2475: undefined reference to `__dev_map_flush'
   net/core/filter.c:2475:(.text+0x24f0): relocation truncated to fit: R_M32R_26_PCREL_RELA against undefined symbol `__dev_map_flush'
   net/core/filter.o: In function `__bpf_tx_xdp':
>> net/core/filter.c:2459: undefined reference to `__dev_map_insert_ctx'
   net/core/filter.c:2459:(.text+0x4528): relocation truncated to fit: R_M32R_26_PCREL_RELA against undefined symbol `__dev_map_insert_ctx'
   net/core/filter.o: In function `xdp_do_redirect_map':
>> net/core/filter.c:2491: undefined reference to `__dev_map_lookup_elem'
   net/core/filter.c:2491:(.text+0x4c5c): relocation truncated to fit: R_M32R_26_PCREL_RELA against undefined symbol `__dev_map_lookup_elem'
   net/core/filter.o: In function `xdp_do_flush_map':
>> net/core/filter.c:2475: undefined reference to `__dev_map_flush'
   net/core/filter.c:2475:(.text+0x4c7c): relocation truncated to fit: R_M32R_26_PCREL_RELA against undefined symbol `__dev_map_flush'

vim +2475 net/core/filter.c

  2441	
  2442	static int __bpf_tx_xdp(struct net_device *dev,
  2443				struct bpf_map *map,
  2444				struct xdp_buff *xdp,
  2445				u32 index)
  2446	{
  2447		int err;
  2448	
  2449		if (!dev->netdev_ops->ndo_xdp_xmit) {
  2450			bpf_warn_invalid_xdp_redirect(dev->ifindex);
  2451			return -EOPNOTSUPP;
  2452		}
  2453	
  2454		err = dev->netdev_ops->ndo_xdp_xmit(dev, xdp);
  2455		if (err)
  2456			return err;
  2457	
  2458		if (map)
> 2459			__dev_map_insert_ctx(map, index);
  2460		else
  2461			dev->netdev_ops->ndo_xdp_flush(dev);
  2462	
  2463		return err;
  2464	}
  2465	
  2466	void xdp_do_flush_map(void)
  2467	{
  2468		struct redirect_info *ri = this_cpu_ptr(&redirect_info);
  2469		struct bpf_map *map = ri->map_to_flush;
  2470	
  2471		ri->map = NULL;
  2472		ri->map_to_flush = NULL;
  2473	
  2474		if (map)
> 2475			__dev_map_flush(map);
  2476	}
  2477	EXPORT_SYMBOL_GPL(xdp_do_flush_map);
  2478	
  2479	int xdp_do_redirect_map(struct net_device *dev, struct xdp_buff *xdp,
  2480				struct bpf_prog *xdp_prog)
  2481	{
  2482		struct redirect_info *ri = this_cpu_ptr(&redirect_info);
  2483		struct bpf_map *map = ri->map;
  2484		u32 index = ri->ifindex;
  2485		struct net_device *fwd;
  2486		int err = -EINVAL;
  2487	
  2488		ri->ifindex = 0;
  2489		ri->map = NULL;
  2490	
> 2491		fwd = __dev_map_lookup_elem(map, index);
  2492		if (!fwd)
  2493			goto out;
  2494	
  2495		if (ri->map_to_flush && (ri->map_to_flush != map))
  2496			xdp_do_flush_map();
  2497	
  2498		err = __bpf_tx_xdp(fwd, map, xdp, index);
  2499		if (likely(!err))
  2500			ri->map_to_flush = map;
  2501	
  2502	out:
  2503		trace_xdp_redirect(dev, fwd, xdp_prog, XDP_REDIRECT);
  2504		return err;
  2505	}
  2506	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--r5Pyd7+fXNt84Ff3
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

H4sICLJIbVkAAy5jb25maWcAjFxbc9s2sH7vr+Ck56GdaRtbvsSZM34AQVBCRRIMAOriF44i
M6mmjuQjyb38+7MASRGkFko708TGLu57+XaxzI8//BiQt+Pu2+q4Wa9eXv4Nvlbbar86Vs/B
l81L9b9BJIJM6IBFXP8GzMlm+/bP+283o31w+9v16LerYFrtt9VLQHfbL5uvb9B1s9v+8OMP
VGQxH5fpzUg+/tv+NmYZk5yWXJEySklHeBIZ67dkouQiF1KXKcmh+cegIwBjsDkE290xOFTH
tsfk6fH66qr9LWJx81PClX589/5l8/n9t93z20t1eP8/RUZSVkqWMKLY+9/WdvHv2r5cfirn
Qk5hWtjJj8HYnsmLmezttdtbKMWUZaXISpXm3cp5xnXJsllJpJk85frxZtQSqRRKlVSkOU/Y
47t33b6atlIzpZHdJYKSZMak4iIz/ZDmkhRadOuYkBkrp0xmLCnHTzzHKSFQRjgpeXIvpD/S
adnuMO6yhwxmMGRbcE2kSHQ5EUqbO3l899N2t61+Pm1QzYmzcrVUM57TswbzN9WJu7BcKL4o
008FKxgycX0RKUuFXJZEa0In3ajxhGQR3I8zXKFYwkN0h6QA5XApVmhAiILD2+fDv4dj9a0T
mpMKgIzlUoQM0Q4gqYmYdxQi6cSsQAGP1jxlIo4V06180rx4r1eHP4Pj5lsVrLbPweG4Oh6C
1Xq9e9seN9uv3fya02kJHUpCqSgyzbNxN0+oIrMoyuBogK7dAxjSytkNehqaqKnSRKuzE5G0
CNT5icASliXQ3Mng15ItciYxVVA1s9tdDfrbRZhR0CWa0WGJSWKULhWZlyljLCoVG9PQGBFk
KWHBk6gMeTZyZJJP6x/cBbVt9ghR9TaDxXDvPNaP17c/nNh5pqelIjEb8tw4tmMsRZErdB90
wug0FzAM2DulhWQom1E+lRO4XpSsYJjIGhg7Fc6zVLECjc4lo0SzCD9WlpAlSgmTKXSeWfsp
I0xlaSlykH7+xMpYyBLEA/5KSUZ7mjpkU/ADJkWtxWh1LAMLyjMRMeUoRB53v9QC2f2eguHi
oJXSnV2BhqYgfXZ8EDF8Zjinht7ra5d0oWdt04wBkKpnhIFdLVOFdbEC5OyocPSdJTGogHRs
UAj+sIyL/rriQrMFemcsF/gW+TgjSRy5agqLdhvYjGXaNnQSkMeXjm0C1tq5L+74OhLNOCy8
6awGhltaHxNjMgVDhkRK3r9EaGRR5JHgnF5f3Z4ZtwYG5dX+y27/bbVdVwH7q9qCFSZgj6mx
w9X+0Fm9WVqfQGmtcH2fDhIgGuCFc20qIWFPVJICd0YqESF2eNAfNivHrHW5/dGAGkvGjJkr
JTg/kfpUXLO0jIgmJaAOHnPQdO6xoGDqYp6Ag8HAmsEZouboaa8l3N+GgKFIAlJkrA41TgcZ
xLrFOYFDNBAgJxJEoIVIfYMA1h6MoBSaUbCAyFB6wjM7Hp+5+p+KqEjA7YIQWWUx1quj5mNN
QoBsCdwkCN1osAu7vAlRE/R0DAYOC/ClOcdsHXhoQLoshhPmRkzA4Z8dk51gBvi43h8OTgyP
sYcCFLIFY3KOq7OPuZUZfyfYJiwC0Iv+T3M47PURe9mlwfGFOYCibxVqZE7F7NfPqwOEK3/W
Cvi630HgUkOe8zkNfyOXcHz9Aftn24IxiDVAISdMwiV49IpnsRhYUJUa0341ECP3Apttg4Oi
xrMT1DjVPEVm6N7ONRndCfA1+oB79WYcQE+nEMJzJi0nH18iG8slB7raYTLJU1gsqFJUTj3e
ysZOBpiBp1M8TFzPBKGOYxCTMCKxSwWPSxUHeQHEr/rItQEWocIX79B9EL/DJpqNJdeXEYyJ
ZvELMRw0jcAostpeSS/bPMTVze4UjlDk5Fwf8tX+uDEReKD/fa0Org7AdJpre8fRzGAmVOJU
JFTH6njrmPea6xBHBGr9R2Viate1cVGjxUwINyxuWiNG7P7PKTT+5F5bGxq2HS5Ej56eZgEX
ejXzPr5bf/m/U7yZfrqwUoc4XYZ9zNASwvgTKtj2zlUObsYoLARhEOa5SQNLlzBlQ79EQ/vO
QS6Zr7NLbHp38A4c/1NfEmth2u/W1eGw2wdHECYbV36pVse3/UCwEmKTNH0/1icXSs781PRm
9OHqqsDsq6WLXOVFT6XrZjJVNyNcg7pF4VmJjo5Hse26AOoVuB4CVMiblV+kX1/hK7D0WcTo
CNm2JZptO7KXukFvEpbgkAC3Kie5ZCCFSbg5+RybaVN5DVGG7QU4ea5U4Ui43bfxlGDprrgb
Z7uUay9l1KMYfEOtPN5d1f/1woEy4jMescfr0YNzLoB8Eq41uBOWRZxkmJmq0zaAeiAeu/rn
6qE/eEuGwM9Qr/tUCwYiruBXzcfAC/OQnqtxiU5SyGzTxIdm/CYr2ZBsnsCGgzksu40h+4Ai
FEKbjgYtWBYMTeSw8zLXVkvhINTjKRFggwLaN8opH0uiB2g3nywBVEaRLHWNo7G0BSAq6mx4
xqUutTD31QsrVXrBfKYGeKYGNsNkj7dXH+8HgMsgcwXIOrdJPGQke2wQU9s7n6Y9zJ4w8FEE
LCqqPLGE+xmOeqI+5ULgMOYpLHDH/GQRWz8105n2KDHuGmInLQFnDyKa7uSZNBs5S361o0iS
diJ79aUnlDWxEdirWmRbmpwrkJsWkBoX0pj4DiRbjgWdjOEuAD+NBZj7CR7CnbAwT8R4VBY3
uHkast3fIltq1zSZMz6eOKmRlgDROA9BRk3UmZClE89aXylSEPdYmly8zVAx560AgCRLc6Nx
WS9AbNtnIoGwgEgcijVceBCbosJotLbNrdUOMHw7BLtXA6cOwU855b8EOU0pJ78EDOznL0FK
4Q/46Wfgth2i6rD5up2v9hVwcoj64Qf19vq62x9bFtPOts+vu8322POilBt7Z48B84OUEulk
T+qFDH+3gURJuWoRWk5/Xa/2z8Hn/eb5a3Xov8sAbHKylm1LmRVpewDsn2r9dlx9fqnsa1Bg
UxtHZxgT+6TahMa9pFI/p2R+A2eT5ifTYULpCcCZXtqjGUtRyXN9Zj6J8PjhplsKNhtzpDC3
mdq11ae8eVYd/97t/4Rgsb3mbmdgbKesjzlsCzgHgiU0iowvemkn+P2Mt4uFEsxCLGLZM4Lm
d5u/QsewVFWEoDoJp7gaWJ7aTeCGtB4ELBZXmlM8cIMTg6B+iZm0rH9EBvEYL0iJwi8LGNro
o5RwowzLxQBTnrmRg/29jCY0H0xmmo1fxd1AwyCJxOlmXzznl4hjI7ksLfDcRM1T6iLLGO5v
1DIDERRT7kmr1yPMNA6dDbWILk5gWGKBP3OY2ymJJ/tkaEx5Dq5eloEcfrqVnAsrs0zn9LMh
UoOowK9myrz2uoFLn8OO5CWHjA37GuUbNGmat839dZpT9iqr5ZBk/h0OQwVhUVoKXBnN7PDj
+FIAfuKhRcgd69xazpYOQevb5836XX/0NLrzZWhAyu59EmTeukvFaEoknkQ028s1zJwQpXiM
b68dCACohfdgVdLch5WAOeaJ9pg2UKqIUq9WK+rReBl5Uk8gzDjK0ThISkaeGULJozEG3a2T
smKgSK9coW5CB5slJCsfrkbXn1AyxIbQG19fQnHYxnNP1lWTBL/bxegOn4LkeC4snwjfsjhj
zOzn7tYrRhb44dulntwbXBKxWSuULHKWzdSca4pbupkSxm977W/Cs6lfs9M8wXtOFC66do92
NRHDF2w4khsIIJU2IfAFrowq7G3AmqOFCdaWxvc7RjH8lAywTXCsDsdBNtxq81QDRvekv1NJ
Ii7wrAXBO3EZ4TLuyWKSGLYgfVoZl1PqeYDSkkGkdJ47behzbop6VC+MpfHYCOU1LuY8PCPW
h9X22lbV8yE47oLPVVBtDRh+NkA4SAm1DA6obloMoLIPP9CyaKK6bsY5h1bcfMVT7sm/mzv7
iJskSniME1g+KX0Z7SzGzz5XYLUTT42AgQUxTkvmF7BApHR5Fsy3oaIUsNLBo621mmxmdBNL
/5ClfZFrOFqRj6q/NusqiPabv+p8dFe8tVk3zYEYAv2ifoadsCR3w89eM8ibnvSqtWBqneYx
huLh8rOIJMJNHEM4aoeLuUznBEClLRxxcktzG7q5Czix8qx5UnMrEQAwnTh6CzuNZAOHdv0x
SZJw8ETYKluSiLl9tnBiJWefYQF/Sj7zuOqGgc2kB+LWDKaqrRmmlCwVM1yKLBsB1ExbZlsj
5cHWqpwsYXczrgS+uFMaIi/MErmvusU88qkJHGVkCmxiJBduUgHPVr56uW/4Kzt7Uu6ch8Y9
ncD1FYyagcBYvq5+WMIetbIiScwvuPFtmCjc8Hmp04Ap6T3XuK02y2dfYR8fkMHlMtciGby1
nLFFMvS/idmdhBggbqmSpOeLM0mzel3X9xjNmt5+ZpJGUqTG/dFohq/H1DYII3pM44jiNINn
Q9ksZWXfvFqZSTeHNSZEimUgwMoUqt4ks6uRBx4Vabo0TzcolWU0EaoAc6GMQnjLuOBUcF8x
GopenQBioH9pcDjlsLoJLaX8eEMX92fddPXP6hDw7eG4f/tmi2AOf6z24DeP+9X2YIYKXjbb
KniGE9m8mh9ba01ejtV+FcT5mARfNvtvf5tc2vPu7+3LbvUc1PW7LS/fHquXIOXUamdt31ua
ouAUz5tnIKTnrd1Ak93h6CVSk0lDpvHy715PL2jquDpWQbrarr5W5kSCn6hQ6c9DZ2XWdxqu
O2s68aCxRWLrDbxEEhetIRW++kBgG4AEN6Qx7zNutNx/t2gOAWBqLdeOpLQSZx7lIUR//Obg
HMIjU3MrUfcJHYDZ7V4XhndCbNoa5O4ZwJZZlvEpD2qX2Kytfs38CWTvz1+C4+q1+iWg0a8g
zD87ec1GxVVv3XQi61bfi2BNFgqvFW3HlO6YXWsJCCFCi5NO847R1XgCH3sO8LPBI57wx7Ik
Yjz2hemWQVETfhmnjF+9bpW6b9Vs15yfX3SfJabf4+D2z+8wKaL+CwtIOvx1gUfmFyUTTmtu
31J7SmEp2pewsFSTpqwrP/2TF7GaUNz613pgoNSli6yX1jwGXBjngsAIFdkqHE58qAb8I452
8JVrIsdMW3CJx7INMHOfNXkvXd+WqHY6I7LIJ7HWTeIu8lNBEv7kwbE2Pcg83hECO5OrwfML
Cx8FeimGR1kwm9FM4Q+0hoW1/ehd2Nr1TEv4wbMhCMd87eXMnqr9AsKzgpkP/GSJr2CeyGG6
qjYHJjzt/P5z3+FFG8AIm89v5oMj9ffmuP4jIPv1H5tjtTaFJg57e4t6YoIh3ZeQ2nSWNwBy
e0829avYDb37gGekOoaHj55MSzM0SQg1NTT2M5FuzyaFSUqtPLJ96p2SJ/flvkeKkCVnKfWJ
FXQoF+OQ1f6ZUezZyx0fxD7T7luhS5R0GHa3lEIKiX2xY0UHAsxB1T0IO4YhnBFDCXHp4ILC
W/xeQpqa2A33s9GAcD4VezIFNOiO4+J3rlWBHHmczn6/flhcHtk8UifowPxhdLdYoKSUSDDL
PZeRzlJfii012knKEKu9cAflVPbd0FQ9PNxdlylaPe/0zAjIa8rRpcKPUmQiZSj14ebjFXJy
ZOG7qoyNrjz1UU3f3JvjBk1HP5Vx1mMsuolr3TV9goaSgThe7ipBvAAJoNuUJmMsUZIiqSqy
3gOSsso4sJdIT8Y+4UOKhMg4IRI/c5Uq93u3lH68XiB3YAn0I/4qYMb4eH39HdlW2siU6O1N
p3CS39/czGNf5vxp8ERct5Tzu2uPXJwYbvoM54MvuMTtvSGMcgzCubtdZhASLXtpx2hOy0Uy
HgiPg3C4aPJIuEhPlr50a557vplK+u/P1imaKPTXw+a5CgoVnsIWw1VVz0322VDaHD95Xr1C
2HwefM3Bh/QPv86Ol/MIOx3DfrL/UaqZU0fao+m+E9STc2iKdktd2+mSHN+AUKmpx8NJA3s8
JEnFeybSfGaKlqK5HTtzjRFZBNDYdzKSNAlpjMYMWvARFccJSuPt2sP/tIxcq+aSLBBgWUYQ
lZFkSc+/2GT2uSOYb8yLxU/n5TI/m2eRQ1UFxz9arg6wdVLnezNSEU7IZunZUvj29e3ozTLw
bFAgbBvKODa1monvi4SayYBp3ytczaHsc9M09ZQb1kwp0ZIvhkx27cWh2r+Y8umN+Qjsy2qQ
/2v6C/NlxMV1/C6WlxnY7Hv0gZY6R3v2ejLoO2XLUBCJB3nOFi6v31QZ4bnqmsV+UOV5XK4Z
REEnCqCP5/WyWcmgGqxLPaX89iwWrY3uav9ss438vQjabEZrpZl0vza0v5o/m4oVJ5NrCOAD
cuVxxJZBkvkFahNTXB4CqKnvg6xmGEm9YxSWBX8yISlDU8H0j9V+tTZupkthtyGlXrqnMMPQ
uamH+/hQ5nrpWKeEjQldehub3P7o7r6/OZKYqtD6nc0jkFk5Vngsb0p4zYdMaO4Q1Keu+e4g
AZtNoek881XtN6sXzNw1K4Rw4OqsV7bb/moJh7q7dexIdr0ZoyBSJ1yjpeI1R7/S0mm0mT+R
nBNtnacairNDuNwzT6K683CtitJs4QE5NUcj2L9rMjYb+w+s32WTuJY35FglZZJ/bxD76Vfh
KRwCIay/oMaNTZ7ysv63IrC87WTefEvbgyBtY/0NBBcD6WrlTl3fXI16Rd43H/tF2E2Fr831
rRHt7Da6zKgtc/EUeJrSYlNic+uL1TqGW5wBDPLoFi9q4HmLOnGDbOrq/M/LmsL/OQIHRhTT
G9OMrs/zcZKCC0QJE+X5mik/R0m5zoP1y279J7YiUzZ3fffwUH8H40NYTeRgMIK3jM6BWqvn
Z/uVH1gQO/HhN3fKcc6FLw6Z41UwuZgzAOgz/I5qqmTK45lruiryPMGqhCfztP+Jim2AmBE3
3TW1LhswaZxzI7o6gtHFTW/9kkpUzjxVZi1L/OH64eoOf4h3eR5GsSfl3jBx/fDhIgOg4uuP
l1ly+vDh5t6jWg7P7ejyOJmmpcmPAvzxZe9PrFTf3z/gH7+5PB8+4OWBLY9JLdx+SHGx6jOF
N985BkUnd/eLxaV/laVlnelrX0VXyzJ/uLkffZhcvuKaiXm47FkSPA8/J6bGT2BBr1Kh+wFz
jRd22836EKjNy2a92wbhav3nK8QEVU98FZZCDWlKzoYL97vV83r3LTi8VuvNl806IGlI3MFM
tzPVSd9ejpsvb9u1/Ua4iaYQRUrj6AwldwqqzT+2oDjFpcf0nbIUgIKXnOp7nywYskrvrvC7
JeHi7urKvzTbe2m+3vOSNS9JenNztyi1oiTyZHoMY+qByJKNi8T7PGYTBP/f2LU1tZHs4Pf9
Fa7ztKk6yQZDWPKQh56L7Ya5MRdseJki4IArC6ZsqD38+yOp5z5Sm6rdIm5penr6KqmlT7QZ
clL0fHf78ogTgTkqvHR8zik3mfyp3u4324m7bQJyP43g1rqVoALCgHgQ12x3+7Se/Hz79QtE
BW8sKswkH1z3IsAQrzJwPe7jWuF/rjCcRHDZAnneG7VpAQfBSKOHwt6RoT10BAap8Jp8QKO5
cD8FjJJ6VSw052GEVVeOYs1ixUUFhys+wKwOfEKd4F2Q1IRSuakQNELURHKxJGqBpiKR7PjB
hRZcd4Hswp4lBMUZsoZfFjrNX5l8LQM8IB06fx5HqRbsAMjih3Cy8vstkQPfFdBniHwzCEXq
Ued+6GhBJST6LJWrhorJuiAzXMtftQSVRfCAoxdfpzJQDjJovFOTqcKCQlq+1NFCMLGZz4pA
253nlpcHLolwMt2P4it+MyRyPNfW1RCquXZl65BhuZ4FElYOMeDdRBbP+G2HOGK0+FpmB8Wm
2Yc4EkKxkAZbns/rgUhNVITiQhBbpl/i5yq4juSNIYHFGQguIEQPFF76R1KoHvGkooM5kjOl
bZ9RXXDJdJSsh55XfY7c9wPUrQUfROIpoiQQdG6kp5JahksJbX8gfsibVBaCyn8eX1tfkWvL
jIalnEkaBNEXaZHlJoRDZCrwJCqTjBeTzKZh2+pWOgrlJt74aWz9QLwJgCUjr3ojA5cLAUmM
jqKAvUYrQMCNF67uAzV0nOeBXgkJ/cImqnzh9o73oi/5Gqs5lHEuI1iePL7vEbB2Ety+o81j
fEbj20CFZr8sihOir1xf8+ZypM6VN2f8Wej1239JfPoHX/tOajvi7Xx2uZbk14nvloUrWBTw
VUWQaNEGVSz58QlDQXaFA1a0skf+EnZzIUzOAK1pRwcSwlEKoj8FAbJUL1SMl73x8wmVU8w6
YdatTIjO/ojHxTepWHk6SyTMyEIQ0QnQwpiVxm252uygFdxQ4WM6hp7tV1t5b9/ttvvtr9fJ
AoZ69/lq8vC23r9ygryJSkD9AkEjeEk4V6LT5WJZYzzw46t04MTcXb4GvbnoLLxe/AsRJ8nt
w9oE9A9wCdL10/Z1jQ7LXMdgyEbuD7FLzYMvT/uH4RrNgPHPjIBeJ/HzxH3cvHxqVdWB03Oj
y2Zbd1jR5ku4GpS3fVhEKy27tEMbSuE0R9KNIFIlIVqEZ6kvONqvclG7JNgZlqSFeZosOduv
Ah0OBCaKHovSH0edehCEQNwpyEJ3yC9wFo7HEDfKLjJvw1wH0Eg7qeOG5UUcKdzFpiIXmjKT
lSqnZ1GIllUh8qzLhfXxXCiousJNbCiEkKZqvAuo5/vddnPf/VpQmdNYsEp6gkiFwR5SqCJf
Ti4LZV99Nbo5Bj30FPvOIm3HD7lGj7bu7T1e4cypoYpWTKTTDIE+zEzoul2u8mnZh6CsisoV
+kszsxjox+NHsKjCsVUur+TWXJnvFkOsvZblZFz3yYfqPpHq7jP5EQU2STob8UheL+eO17u6
wd8iM7QmdCg6snfb42sErgVVmV/r5zJpJZPms2wq0Zzc8rpIB5ZHZ1P5SYSEFtaONFpNF+M5
NhxlU2bgIIdBLXW9iO6J9B64eYjXxTkCgw3o3fbwo97QozjXsw6MkTcs0KagHMJCz5QhsP1w
WcSCTz1R3Jyfy4jGPctOxI7HEFmBhvFtIFMNyGbruL17HNgEs1HsriFT1MxfGEeHm8Zoz9BZ
/P309Cuu0yae5zwOdN8h8AbY2Djawpv1HsXfUdCE9Hhx9tdM5X9FOf92oPUeN9CW3ZKrIQv+
biAlY89H6e3HyfHfHF3H7gK9gvIf/9nst2dn375/PuqG4XZYi3x2xi+qfLRszHG8X7/dbwly
afRZbWBTt+Ci7wdAZUOAcyokFLMwjjQshJ4bGBLdhQ681OemPkYgd99KkSztT4qF7tZHBQf2
YsMzOj5aObgA/StwSlGINn9GfVgPuM6MYmFAq3vNi1MVzX1501KehTaTaQsrCdV1cfe1tMaR
SZanXBCMpWijy0JlC4F4ZTk/Qo2wVgeI6GCurzj4xrb/Q0tHJTLtMlqdWKmnMjW1vTSRMyNg
ihHpsUKafPUtfn/+1UR6qv/7ajr4fdwLzKAScSURWcBcQWGHh19MMSQt6q9b+MndkczJaSpB
d5UOagEeocOf0I7+h5jL3M7OUURp0os6MSWW6DYCspBmuZYkFjcRn4k9Ja9uaUSD7ogFWYOj
z+7/yFAfISUcIXwTu0x/f4hJuI3vMZ194z0JBky8fjVg+tDrPtDwM8G7YcDE3/oOmD7S8FPe
6DpgEpZMn+kjXXAqYGv1mb4fZvp+/IGavn9kgL8LwJ59ppMPtOlMCJ5DJhDecO6XgoDTreZo
+pFmA5c8CVTmagEqr9MW+fmaQ+6ZmkOePjXH4T6RJ07NIY91zSEvrZpDHsCmPw5/zNHhrzmS
P+ci1melEFZbk3mIQiRjgBGczYKkUHO4PuJKHmCJcr9IeUtbw5TGIJ0cetl1qoPgwOvmyj/I
kvrCVVvNoeG7VCT4MNc8UaGF8Lpu9x36qLxIL7RwwYo8QzXlj05am8fbu98GRYxKX3ab59ff
dO9x/7TeP3B2/SpzFbowMqepa3yM8erYxKzXp2mjbIV+luGGMOI46QjGKMFUL/KGiaVMY7ZP
L6BGfabMaKDY3v3eU7PvTPluDPxqHA+rnB6t+a8pLREkyZUw7Fo2wvI+xOQtVTrj197ccyos
XE4aMZDlJTwedTJudRCiDD0sEHkLM4B1gKUIbxmf/HH0ddrpTUzIksAeG5bD7Bwdq5TyqGIl
eNdX+T2gAicWkPPM57MyVoUJ3LR48EzmEwA6anahGuD91d8wYDE9FEdBL0KhBzltayQlWFn6
6qKGKecVH3RvQD0h5VI/mKoaCC9zmbR+2u7eJ97659vDwwCej45Bf5Wj24ZgfDRVIqMMWk7V
wCdmoOxLWAlUTeycQ6fZxgqT3NjImHyoLDJJTTdcV/yEMcQKsR+BJ7hpgYHunXeh9WoWUIJE
rik12dbkxQBIyZiUcDgmwfbu99uL2SYWt88PvV0NdZwCgazHmaQ6r0BiuSgik4iQZVpesh6k
neGLYE7BTI55G2ePXl6poPDbfEOGSIkii7wtrtOamBxw7bqnYtyPeP0XySNQ+8HTZg6Axm/W
rqXrsVUXvj9EhqVOxq5vF8Xkz/3L5pn82/87eXp7Xf9vDf9Yv959+fLlU8/n0Yyp7dK0mmaY
yM6KU6fyOMS1HEALLWyV8RiTd8GWE8wQt46vlszUMFNyxOYa5nZtZ8PStK2pzPLuC7Ng7esE
/odV4MSZP14kLc32hdraiEQf4hCSLRkiGcO1L6D1VL7/cND6iFzRP0f+qFOJ8ptnCqtfTPx5
cBww6SemlbRzfKgaijMTqf5lZjF4mA6ALcIcQKl89FQjSrMMzgzCpeQlvKrHSz9NKTj63JyU
LHNl4uZ4TPdjVlkQqPIxuCwhOFIawUxyESYWkYquxlWMHqYJkPvYyUG6lul0tsO+WNrZqqQd
It1sCKcn9pVJn7TwVwifaflmELCieYXJKQScId8FMOYxf2dGDCTyCiELSHd0LgUrE70ohFtu
oqYIXUuBuJZvlVw1zfhfCLGX9HLEJXXjRABJp/Ynlo+rYU8tbxjpAsNxABXQRX9fwd6OUlFk
sly6cZoW8jWwQcsVTIltEpzCyVSECR2jQoB1Ig5mT2885kxoKqjjBrHV7/nPVbkUDc9ouWbr
u7fd5vWdU9PETqhvyEsPNDHyLaF3WHmtRF7ixyNroVLY6UGKwKmBM4M+0VWDO6oRG/86M7jI
g5kBzGJjxXKzy7XfqRi8/ZraSblu8E5rSd7dvb+8bkGf3K0n293kcf3PC4E39pgxJQ+ICm31
veLpuBz0oPZaslM4ZnWCC1cnCz8dk3CNsoVj1jSaj94HZSxjo4iPGii25CJJmI/E/BI9N4n6
HQJcfkUW0Osqqu96nF5YUUMVgZaSjppelXOtGeZfYR/ElGGkF5MgyNQynx1Nz8KCc3OoOHBn
GLULC8c9hzdLlNeeeRH94Tf3usmHWVSRL/yI1ysrluFRaHyq3l4f1yAa3N0inpv/fIeLA/2Y
/t28Pk7Ufr+92xDJu3297e5CdeMF1Pe6E+1kd6Hgv+nXJA6uj46/8vbKijfzL/uuv8NZtFCg
jF7BgBgXRQrvfdreD+Cfqxc71q5yhfvthizd31ZN4XXvihykvJ5bkZMDbVvZXw6nwzJlEE0W
t/tHuTt48K16AwJqD8a0asiBhl4NKq3QAx9AAh3ttm7qHk9ddnG4wq1Iy5AfffUkQP1qGorC
T93pH5iAoceb/Rqy/WkNE9QP8K+NLQ092HYOcQhXcy3H9Bt/UdFyHE+tdWQLdSTPCKDCG5g5
AYRvR9bxAg7+cqPepebpkYCJVu+lyeAVZkJvXh57sJPNGcxt7lAqeRrXHFHhaOtKAznPOiFA
xVvOJPN9PXtV6AeBEBjT8GS5dWohg3W4PUHcrcgz+mvdVBbqRkhYXQ8r6PzKPqXqzd6+yQtm
+oaeJoO03uNjztqb+TIeDkpz7bBb7/eD4NymBzGXqODTVG3rNwLityGfnVgndXBjnUtAXjCO
/LfP99unSfT29HO9M2EDo+jiZjojtHSSRpw/a/2RqYN23agYCTVEoWNgvJQMbbC/jllGdZ5r
jA3GlLigFzBbCSmdaK07tHc3jFklzX6IORUs7EM+lOEtR+OS6xH/ioBsXIXJDqr+TxAMOhuP
obvevWKIBQhZe4IJxHyUlLLZXH4NjDWOjlR6zZgTjDV283N3u3uf7LZvr5vnLuCTo3NMaJL2
rYsmTyPqqy2d+dg6poDyruW661ZTk/oAQ3Aog2QIA8z2nHt0OmQeH+Edos6Lsqe7gEgwqOB4
ylp7+gyBdn3n+ox51FCkFUgsKl3KGwByOMLdoSsfEy7vKxBox8hD0mO8fKAKT+dmNCn1cF4P
Dm+MI7QBod8artUN5jSzkErHPWeNBFlJOEntTCGLSNgBHcUULpjvHV3CeyZvKKdoMP4axbvs
ovkG6Is6no61DbA31nHqCZ3heUJWu/SyFGG9s/n4xrglYULjHuRmbRXKECNHac5ylBkrIDz2
f+ooBKPmjwAA

--r5Pyd7+fXNt84Ff3--
