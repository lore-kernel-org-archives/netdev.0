From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: sendfile from 9p fs into af_alg
Date: Wed, 23 Nov 2016 00:58:11 -0800
Message-ID: <20161123085809.GA46992@ast-mbp.thefacebook.com>
References: <20161123035827.GA43786@ast-mbp.thefacebook.com>
 <20161123044625.GL1555@ZenIV.linux.org.uk>
 <20161123045558.GA43893@ast-mbp.thefacebook.com>
 <20161123061628.GN1555@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161123061628.GN1555@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 23, 2016 at 06:16:28AM +0000, Al Viro wrote:
> On Tue, Nov 22, 2016 at 08:55:59PM -0800, Alexei Starovoitov wrote:
> > On Wed, Nov 23, 2016 at 04:46:26AM +0000, Al Viro wrote:
> > > On Tue, Nov 22, 2016 at 07:58:29PM -0800, Alexei Starovoitov wrote:
> > > > Hi Al,
> > > > 
> > > > it seems the following commit 523ac9afc73a ("switch default_file_splice_read() to use of pipe-backed iov_iter")
> > > > breaks sendfile from 9p fs into af_alg socket.
> > > > sendfile into af_alg is used by iproute2/tc.
> > > > I'm not sure whether it's 9p or crypto or vfs problem, but happy to test any patches.
> > > 
> > > Could you try -rc6 (or anything that contains 680bb946a1ae04, for that
> > > matter)?
> > 
> > already tested with that patch in the latest net-next. Still broken :(
> 
> Joy...  Which transport are you using there?  The interesting part is
> whether it's zerocopy or non-zerocopy path in p9_client_read()...

not sure what's the default is. It's a standard qemu setup:
sudo /usr/bin/qemu-system-x86_64 -enable-kvm -smp 4 -cpu host \
 -kernel .../bld_x64/arch/x86/boot/bzImage \
 -drive file=....qcow2,if=virtio \
 -no-reboot -m 4096 \
 --append "root=/dev/vda1 rw mem=GG vga=0 console=ttyS0" -nographic \
 -fsdev local,security_model=passthrough,id=fsdev1,path=/data/users \
 -device virtio-9p-pci,id=fs1,fsdev=fsdev1,mount_tag=hostshare1

Enabled CONFIG_NET_9P_DEBUG and everything looks normal:
# ./a.out ./a.out
[   23.894140] 9pnet: -- v9fs_vfs_lookup (235): dir: ffff8801370d87f8 dentry: (a.out) ffff880139ffe600 flags: 0
[   23.895409] 9pnet: -- v9fs_fid_find (235):  dentry: bpf (ffff880139ffc180) uid 0 any 0
[   23.896451] 9pnet: -- p9_fid_create (235): clnt ffff880136d8f000
[   23.897225] 9pnet: -- p9_idpool_get (235):  id 6 pool ffff880139b76640
[   23.898052] 9pnet: (00000235) >>> TWALK fids 5,6 nwname 1d wname[0] a.out
[   23.898919] 9pnet: -- p9_client_prepare_req (235): client ffff880136d8f000 op 110
[   23.899884] 9pnet: -- p9_idpool_get (235):  id 1 pool ffff880139b76c00
[   23.900738] 9pnet: (00000235) >>> size=24 type: 110 tag: 1
[   23.901452] 9pnet: -- p9_virtio_request (235): 9p debug: virtio request
[   23.902332] 9pnet: -- p9_virtio_request (235): virtio request kicked
[   23.903374] 9pnet: -- req_done (235): : request done
[   23.903377] 9pnet: -- p9_client_cb (235):  tag 1
[   23.903378] 9pnet: -- p9_client_cb (235): wakeup: 1
[   23.905213] 9pnet: (00000235) <<< size=22 type: 111 tag: 1
[   23.905904] 9pnet: -- p9_free_req (235): clnt ffff880136d8f000 req ffff880138eac070 tag: 1
[   23.906943] 9pnet: -- p9_idpool_put (235):  id 1 pool ffff880139b76c00
[   23.907847] 9pnet: (00000235) <<< RWALK nwqid 1:
[   23.908446] 9pnet: (00000235) <<<     [0] 0.170dd824.58117466
[   23.909184] 9pnet: (00000235) >>> TGETATTR fid 6, request_mask 6143
[   23.909980] 9pnet: -- p9_client_prepare_req (235): client ffff880136d8f000 op 24
[   23.910887] 9pnet: -- p9_idpool_get (235):  id 1 pool ffff880139b76c00
[   23.911737] 9pnet: (00000235) >>> size=19 type: 24 tag: 1
[   23.912426] 9pnet: -- p9_virtio_request (235): 9p debug: virtio request
[   23.913266] 9pnet: -- p9_virtio_request (235): virtio request kicked
[   23.914159] 9pnet: -- req_done (235): : request done
[   23.914161] 9pnet: -- p9_client_cb (235):  tag 1
[   23.914162] 9pnet: -- p9_client_cb (235): wakeup: 1
[   23.915982] 9pnet: (00000235) <<< size=160 type: 25 tag: 1
[   23.916691] 9pnet: (00000235) <<< RGETATTR st_result_mask=6143
<<< qid=0.170dd824.58117466
<<< st_mode=000081ed st_nlink=1
<<< st_uid=572438 st_gid=100
<<< st_rdev=0 st_size=2598 st_blksize=4096 st_blocks=24
<<< st_atime_sec=1479863398 st_atime_nsec=904285549
<<< st_mtime_sec=1479863398 st_mtime_nsec=914285509
<<< st_ctime_sec=1479863398 st_ctime_nsec=914285509
<<< st_btime_sec=0 st_btime_nsec=0
<<< st_gen=1570962252 st_data_version=0[   23.921484] 9pnet: -- p9_free_req (235): clnt ffff880136d8f000 req ffff880138eac070 tag: 1
[   23.922536] 9pnet: -- p9_idpool_put (235):  id 1 pool ffff880139b76c00
[   23.923368] 9pnet: -- v9fs_file_open (235): inode: ffff8801370d0568 file: ffff88013a566500
[   23.924451] 9pnet: -- v9fs_fid_find (235):  dentry: a.out (ffff880139ffe600) uid 0 any 0
[   23.925483] 9pnet: -- p9_fid_create (235): clnt ffff880136d8f000
[   23.926263] 9pnet: -- p9_idpool_get (235):  id 7 pool ffff880139b76640
---skip---
[   24.044275] 9pnet: -- req_done (123): : request done
[   24.044278] 9pnet: -- p9_client_cb (123):  tag 1
[   24.044278] 9pnet: -- p9_client_cb (123): wakeup: 1
[   24.047135] 9pnet: (00000235) <<< size=4107 type: 117 tag: 1
[   24.047879] 9pnet: (00000235) <<< RREAD count 4096
[   24.048520] 9pnet: -- p9_free_req (235): clnt ffff880136d8f000 req ffff880138eac070 tag: 1
[   24.049609] 9pnet: -- p9_idpool_put (235):  id 1 pool ffff880139b76c00
[   24.050462] 9pnet: -- p9_client_prepare_req (235): client ffff880136d8f000 op 116
[   24.051431] 9pnet: -- p9_idpool_get (235):  id 1 pool ffff880139b76c00
[   24.052283] 9pnet: (00000235) >>> size=23 type: 116 tag: 1
[   24.052984] 9pnet: -- p9_virtio_zc_request (235): virtio request
[   24.053774] 9pnet: -- p9_virtio_zc_request (235): virtio request kicked
[   24.053834] 9pnet: -- req_done (123): : request done
[   24.053836] 9pnet: -- p9_client_cb (123):  tag 1
[   24.053836] 9pnet: -- p9_client_cb (123): wakeup: 1
[   24.056496] 9pnet: (00000235) <<< size=4107 type: 117 tag: 1
[   24.057211] 9pnet: (00000235) <<< RREAD count 4096
[   24.057820] 9pnet: -- p9_free_req (235): clnt ffff880136d8f000 req ffff880138eac070 tag: 1
[   24.058857] 9pnet: -- p9_idpool_put (235):  id 1 pool ffff880139b76c00
[   24.059800] 9pnet: -- v9fs_dir_release (235): inode: ffff8801370d0568 filp: ffff880139ab2800 fid: 8
Error from sendf[   24.060938] 9pnet: (00000235) >>> TCLUNK fid 8 (try 0)
ile (8192 vs 962[   24.061731] 9pnet: -- p9_client_prepare_req (235): client ffff880136d8f000 op 120
4 bytes): Succes[   24.062787] 9pnet: -- p9_idpool_get (235):  id 1 pool ffff880139b76c00
s
[   24.063715] 9pnet: (00000235) >>> size=11 type: 120 tag: 1
[   24.064461] 9pnet: -- p9_virtio_request (235): 9p debug: virtio request
[   24.065335] 9pnet: -- p9_virtio_request (235): virtio request kicked
[   24.065410] 9pnet: -- req_done (0): : request done
[   24.065412] 9pnet: -- p9_client_cb (0):  tag 1
[   24.065413] 9pnet: -- p9_client_cb (0): wakeup: 1
[   24.068025] 9pnet: (00000235) <<< size=7 type: 121 tag: 1
[   24.068695] 9pnet: (00000235) <<< RCLUNK fid 8
[   24.069253] 9pnet: -- p9_free_req (235): clnt ffff880136d8f000 req ffff880138eac070 tag: 1
[   24.070269] 9pnet: -- p9_idpool_put (235):  id 1 pool ffff880139b76c00
[   24.071120] 9pnet: -- p9_fid_destroy (235): fid 8
[   24.071735] 9pnet: -- p9_idpool_put (235):  id 8 pool ffff880139b76640
hash 0

if I read it correctly 9p actually responded with 8192 bytes of requests...
whereas the file size was 9624.
For large file sizes (in megabytes) the difference between what
sendfile is reporting and actual file size can be 3x.
In the small file case (like above dump) it looks rounded to page size for some reason.
 
