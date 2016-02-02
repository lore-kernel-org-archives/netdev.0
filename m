From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] virtio_net: add ethtool support for set and get
	of settings
Date: Tue, 2 Feb 2016 14:52:30 +0100
Message-ID: <56B0B49E.8020902@cumulusnetworks.com>
References: <1454417480-28672-1-git-send-email-razor@blackwall.org>
	<20160202151658-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>,
	davem@davemloft.net, virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20160202151658-mutt-send-email-mst@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 02/02/2016 02:23 PM, Michael S. Tsirkin wrote:
> On Tue, Feb 02, 2016 at 01:51:20PM +0100, Nikolay Aleksandrov wrote:
>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>
>> This patch allows the user to set and retrieve speed and duplex of the
>> virtio_net device via ethtool. Having this functionality is very helpful
>> for simulating different environments and also enables the virtio_net
>> device to participate in operations where proper speed and duplex are
>> required (e.g. currently bonding lacp mode requires full duplex). Custom
>> speed and duplex are not allowed, the user-supplied settings are validated
>> before applying. Only full and unknown duplex are allowed to be set.
> 
> Why isn't half duplex legal?
> 

It is legal, I'm just not sure it makes sense. Isn't the virtual channel
always "full duplex" ?
At first I had allowed it, but then I decided against and removed it. I
don't mind adding it back though, the argument against is not strong.

>>
>> Example:
>> $ ethtool eth1
>> Settings for eth1:
>> ...
>> 	Speed: Unknown!
>> 	Duplex: Unknown! (255)
>> $ ethtool -s eth1 speed 1000 duplex full
>> $ ethtool eth1
>> Settings for eth1:
>> ...
>> 	Speed: 1000Mb/s
>> 	Duplex: Full
>>
>> Based on a patch by Roopa Prabhu.
>>
>> CC: Roopa Prabhu <roopa@cumulusnetworks.com>
>> CC: Michael S. Tsirkin <mst@redhat.com>
>> CC: virtualization@lists.linux-foundation.org
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> Thanks!
> Looks ok with one comment, see below.
> 
>> ---
>> Allowed to set unknown speed/duplex if the user wants to reset them, though
>> the user-space ethtool tool currently doesn't allow setting them.
>>
>>  drivers/net/virtio_net.c | 74 ++++++++++++++++++++++++++++++++++++++++++++++++
>>  1 file changed, 74 insertions(+)
>>
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index 767ab11a6e9f..722ade567ee5 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -146,6 +146,10 @@ struct virtnet_info {
>>  	virtio_net_ctrl_ack ctrl_status;
>>  	u8 ctrl_promisc;
>>  	u8 ctrl_allmulti;
>> +
>> +	/* Ethtool settings */
>> +	u8 duplex;
>> +	u32 speed;
>>  };
>>  
>>  struct padded_vnet_hdr {
>> @@ -1376,6 +1380,72 @@ static void virtnet_get_channels(struct net_device *dev,
>>  	channels->other_count = 0;
>>  }
>>  
>> +static bool virtnet_validate_speed(u32 speed)
>> +{
>> +	switch (speed) {
>> +	case SPEED_10:
>> +	case SPEED_100:
>> +	case SPEED_1000:
>> +	case SPEED_2500:
>> +	case SPEED_5000:
>> +	case SPEED_10000:
>> +	case SPEED_20000:
>> +	case SPEED_25000:
>> +	case SPEED_40000:
>> +	case SPEED_50000:
>> +	case SPEED_56000:
>> +	case SPEED_100000:
>> +	case SPEED_UNKNOWN:
>> +		return true;
>> +	}
>> +
>> +	return false;
>> +}
>> +
>> +static bool virtnet_validate_duplex(u8 duplex)
>> +{
>> +	switch (duplex) {
>> +	case DUPLEX_FULL:
>> +	case DUPLEX_UNKNOWN:
>> +		return true;
>> +	}
>> +
>> +	return false;
>> +}
> 
> Let's put the validating functions near where the
> enums are defined so people remember to extend these
> when adding new speeds?
> Will help e.g. tun reuse this, too.
> 

Right, very good suggestion. I'll split this patch in two and will
add them for everyone to use.

Thank you,
 Nik

>> +
>> +static int virtnet_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
>> +{
>> +	struct virtnet_info *vi = netdev_priv(dev);
>> +	u32 speed = ethtool_cmd_speed(cmd);
>> +
>> +	/* don't allow custom speed and duplex */
>> +	if (!virtnet_validate_speed(speed) ||
>> +	    !virtnet_validate_duplex(cmd->duplex))
>> +		return -EINVAL;
>> +	vi->speed = speed;
>> +	vi->duplex = cmd->duplex;
>> +
>> +	return 0;
>> +}
>> +
>> +static int virtnet_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
>> +{
>> +	struct virtnet_info *vi = netdev_priv(dev);
>> +
>> +	ethtool_cmd_speed_set(cmd, vi->speed);
>> +	cmd->duplex = vi->duplex;
>> +
>> +	return 0;
>> +}
>> +
>> +static void virtnet_init_settings(struct net_device *dev)
>> +{
>> +	struct virtnet_info *vi = netdev_priv(dev);
>> +
>> +	vi->speed = SPEED_UNKNOWN;
>> +	vi->duplex = DUPLEX_UNKNOWN;
>> +}
>> +
>>  static const struct ethtool_ops virtnet_ethtool_ops = {
>>  	.get_drvinfo = virtnet_get_drvinfo,
>>  	.get_link = ethtool_op_get_link,
>> @@ -1383,6 +1453,8 @@ static const struct ethtool_ops virtnet_ethtool_ops = {
>>  	.set_channels = virtnet_set_channels,
>>  	.get_channels = virtnet_get_channels,
>>  	.get_ts_info = ethtool_op_get_ts_info,
>> +	.get_settings = virtnet_get_settings,
>> +	.set_settings = virtnet_set_settings,
>>  };
>>  
>>  #define MIN_MTU 68
>> @@ -1855,6 +1927,8 @@ static int virtnet_probe(struct virtio_device *vdev)
>>  	netif_set_real_num_tx_queues(dev, vi->curr_queue_pairs);
>>  	netif_set_real_num_rx_queues(dev, vi->curr_queue_pairs);
>>  
>> +	virtnet_init_settings(dev);
>> +
>>  	err = register_netdev(dev);
>>  	if (err) {
>>  		pr_debug("virtio_net: registering device failed\n");
>> -- 
>> 2.4.3
